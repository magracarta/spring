import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import test.MaskingUtil;

import java.util.*;

class MaskingUtilTest {

    @Test
    void testMakeMasking() {

        Map<String, Object> bean = new HashMap<>();
        bean.put("name", "John Doe");
        bean.put("phone", "010-1234-5678");
        bean.put("email", "john.doe@example.com");
        bean.put("age", 30); // 문자열이 아닌 값 (마스킹 제외)
        bean.put("gender", "male");

        Set<String> noField = new HashSet<>();
        noField.add("gender");

        Map<String, MaskingUtil.Masking> propMap = new HashMap<>();
        propMap.put("name", new MaskingUtil.Masking(true, 0, 4));
        propMap.put("email", new MaskingUtil.Masking(true, 0, 4));
        propMap.put("phone", new MaskingUtil.Masking(true, 4, 4));

        Map<String, Object> result = MaskingUtil.makeMasking(bean, noField, propMap);

        assertNotNull(result);
    }
}
