import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;
import test.CmdUtil;
import test.CollectionUtil;

import java.util.*;

import static com.fasterxml.jackson.databind.type.LogicalType.Collection;
import static org.junit.jupiter.api.Assertions.*;

class test_util {

    //todo :: Cmd_exec()

    @Test
    void exec_true() {
        String command = "echo hello";
        String result = CmdUtil.exec(command);
        assertEquals("hello", result.trim());
    }

    @Test
    void exec_null() {
        String command = "test1234";
        String result = CmdUtil.exec(command);
        assertTrue(result.isEmpty(), "null 확인");
    }

    //todo :: CollectionUtil

    @Test
    void CollectionUtil_mapListToMap() {

        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", "111");
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        Map<String, List<Map<String, Object>>> result = CollectionUtil.mapListToMap(listMap, "aaa");

        assertNotNull(result);

    }

    @Test
    void CollectionUtil_mapListToOneMap() {

        // given
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", "111");
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        // when

        Map<String, Map<String, Object>> result = CollectionUtil.mapListToOneMap(listMap, "aaa");

        // then

        assertNotNull(result);

    }

    @Test
    void CollectionUtil_mapListToMap_Group() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", "111");
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        Map<String, List<Map<String, Object>>> result = CollectionUtil.mapListToMap(listMap, "aaa", null);
        assertNotNull(result);

    }


    @Test
    void CollectionUtil_mapListToArray() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", "111");
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        String[] result = CollectionUtil.mapListToArray(listMap, "aaa");
        assertNotNull(result);

        String[] result2 = CollectionUtil.mapListToArray(listMap, "bbb");
        assertNotNull(result2);

    }

    @Test
    void CollectionUtil_removeEmptyElement() {
        String[] test = new String[]{"", "bbb", "ccc"};

        CollectionUtil.removeEmptyElement(test);

        String[] result = CollectionUtil.removeEmptyElement(test);
        assertNotNull(result);

    }

    //beanToMap | beanUtil 사용

    @Test
    void CollectionUtil_null2Blank() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", null);
        map1.put("bbb", "abc");

        Map<String, String> result = CollectionUtil.null2Blank(map1);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_listToStringArray() {
        List<String> list = new ArrayList<>();
        list.add("aaa");
        list.add("bbb");
        list.add("ccc");

        String[] result = CollectionUtil.listToStringArray(list);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_removeDupList() {
        List<String> list = new ArrayList<>();
        list.add("aaa");
        list.add("aaa");
        list.add("ccc");

        List<String> result = CollectionUtil.removeDupList(list);
        assertNotNull(result);

    }

    //toGetString | get 형식으로 변환, 기본 euc-kr 인코딩 | httpUtil 사용

    //toGetString2 | 요소를 모두 get 형식으로 변환, 값은 모두 euc-kr 인코딩 | toGetString 을 위한 메서드

    @Test
    void CollectionUtil_merge() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("ddd", null);
        map2.put("ccc", null);

        Map<String, Object> result = CollectionUtil.merge(map1, map2);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_toStringMap() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "abc");
        map1.put("bbb", 123);
        map1.put("ccc", true);
        map1.put("ddd", null);

        Map<String, String> result = CollectionUtil.toStringMap(map1);
        assertNotNull(result);

    }


    //todo - test fail
    @Test
    void CollectionUtil_toObjectMap() {

        Map<String, String> map1 = new HashMap<>();
        map1.put("aaa", "null");
        map1.put("bbb", "123");

        Map<String, Object> result = CollectionUtil.toObjectMap(map1);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_listToStringMap() {

        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", 111);
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("bbb", null);
        map2.put("ccc", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("ddd", true);
        map3.put("eee", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        List<Map<String, String>> result = CollectionUtil.listToStringMap(listMap);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_toStringList() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", 123);
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        List<String> result = CollectionUtil.toStringList(listMap, "aaa");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_keyList() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", null);
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", 123);
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        List<Map<String, Object>> result = CollectionUtil.keyList(listMap, "ccc");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_keyMap() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", 123);
        map1.put("bbb", "abc");

        Map<String, Object> result = CollectionUtil.keyMap(map1, true, "ccc");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_toStringList2() {

        List<String> result = CollectionUtil.toStringList("aaa", "123", "ㄱㄴㄷ");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_convertLowerMapKey() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("AAA", "111");

        Map result = CollectionUtil.convertLowerMapKey(map1);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_convertUpperMapKey() {
        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");

        Map result = CollectionUtil.convertUpperMapKey(map1);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_add() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", 456);
        map3.put("bbb", "123");

        listMap.add(map1);

        List<Map<String, Object>> result = CollectionUtil.add(listMap, map3, "aaa", true);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_createMap() {

        Map<String, Object> result = CollectionUtil.createMap( "aaa", "bbb", "ccc", "ddd");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_convertMap() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object>  result = CollectionUtil.convertMap(map1, "ccc");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_convertList() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", "111");
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        List<Map<String, Object>> result = CollectionUtil.convertList(listMap, "aaa");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_copyMap() {

        //원본 맵의 값을 새로운 키로 변경함

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", 123);
        map1.put("bbb", null);

        Map<String, String> map2 = new HashMap<>();
        map2.put("aaa", "111");
        map2.put("bbb", "def");

        Map<String, Object> result = CollectionUtil.copyMap(map1, map2);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_addPrefixKey() {

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", "111");
        map1.put("bbb", "abc");

        Map<String, Object> result = CollectionUtil.addPrefixKey(map1, "aaa");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_addPrefixMapList() {
        List<Map<String, Object>> listMap = new ArrayList<>();

        Map<String, Object> map1 = new HashMap<>();
        map1.put("aaa", 123);
        map1.put("bbb", "abc");

        Map<String, Object> map2 = new HashMap<>();
        map2.put("aaa", null);
        map2.put("bbb", "def");

        Map<String, Object> map3 = new HashMap<>();
        map3.put("aaa", "222");
        map3.put("bbb", "gif");

        listMap.add(map1);
        listMap.add(map2);
        listMap.add(map3);

        List<Map<String, Object>> result = CollectionUtil.addPrefixMapList(listMap, "aaa");
        assertNotNull(result);

    }

    //구분자 생성
    @Test
    void CollectionUtil_convertList2() {

        List<String> result = CollectionUtil.convertList("test@test2@test3", "@", true);
        assertNotNull(result);

    }

    //구분자 반환
    @Test
    void CollectionUtil_convertString() {

        List<String> list = new ArrayList<>();
        list.add("aaa");
        list.add("bbb");

        String result = CollectionUtil.convertString(list, "@");
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_partitionBasedOnSize() {
        List<Object> list = new ArrayList<>();
        list.add("aaa");
        list.add("111");
        list.add("ccc");
        list.add("222");
        list.add("eee");
        list.add(333);

        Collection<List<Object>> result = CollectionUtil.partitionBasedOnSize(list, 2);
        assertNotNull(result);

    }

    @Test
    void CollectionUtil_unique() {
        String[] StringArray = {"aaa", "aaa", "bbb", "ccc", "ddd"};

        String[] result = CollectionUtil.unique(StringArray);
        assertNotNull(result);

    }

}
