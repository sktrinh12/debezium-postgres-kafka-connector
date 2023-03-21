package com.kinnate;

import java.sql.SQLException;
import java.util.Properties;
import java.util.function.Predicate;

import org.apache.kafka.connect.data.SchemaBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.debezium.function.Predicates;
import io.debezium.spi.converter.CustomConverter;
import io.debezium.spi.converter.RelationalColumn;
import io.debezium.util.Strings;

import oracle.sql.NUMBER;

public class NumberToIntegerConverter implements CustomConverter<SchemaBuilder, RelationalColumn> {

    private static final Logger LOGGER = LoggerFactory.getLogger(NumberToIntegerConverter.class);
    private static final Integer FALLBACK = 0;

    public static final String SELECTOR_PROPERTY = "selector";

    private Predicate<RelationalColumn> selector = x -> true;

    @Override
    public void configure(Properties props) {
        final String selectorConfig = props.getProperty(SELECTOR_PROPERTY);
        if (Strings.isNullOrEmpty(selectorConfig)) {
            return;
        }
        selector = x -> x.name().equalsIgnoreCase("ID");
    }

    @Override
    public void converterFor(RelationalColumn field, ConverterRegistration<SchemaBuilder> registration) {
        if (!"NUMBER".equalsIgnoreCase(field.typeName()) || !selector.test(field)) {
            return;
        }

        registration.register(SchemaBuilder.int32(), x -> {
            if (x == null) {
                if (field.isOptional()) {
                    return null;
                }
                else if (field.hasDefaultValue()) {
                    return field.defaultValue();
                }
                else {
                    return FALLBACK;
                }
            }
            if (x instanceof Integer) {
                return x;
            }
            else if (x instanceof Number) {
                return ((Number) x).intValue();
            }
            else if (x instanceof NUMBER) {
                try {
                    return ((NUMBER) x).intValue();
                }
                catch (SQLException e) {
                    // ignored, use fallback below
                }
            }
            else if (x instanceof String) {
                try {
                    return Integer.parseInt((String) x);
                }
                catch (NumberFormatException e) {
                    LOGGER.warn("Cannot convert '{}' to integer", x);
                    return FALLBACK;
                }
            }
            LOGGER.warn("Cannot convert '{}' to integer", x.getClass());
            return FALLBACK;
        });
    }
}
