package hello.core2;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;

@Configuration
@ComponentScan (
        basePackages = "hello.core2",
        basePackageClasses = AutoAppConfig.class,
        excludeFilters = @ComponentScan.Filter (type = FilterType.ANNOTATION, classes = Configuration.class)
)
public class AutoAppConfig {

}
