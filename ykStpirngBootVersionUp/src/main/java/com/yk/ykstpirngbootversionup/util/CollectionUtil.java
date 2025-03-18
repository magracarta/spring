package com.yk.ykstpirngbootversionup.util;

// import static org.mockito.Mockito.RETURNS_DEEP_STUBS;

import java.util.*;


/**
 * collect 객체를 가공하기 위한 클래스
 *
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 27
 */
public class CollectionUtil {	/**
    /**
     * <String, String> 타입으로 변환
     * @param map
     * @return
     */
    public static Map<String, String> toStringMap(Map<String, Object> map) {
        if(map == null) {
            return null;
        }

        Map<String, String> retMap = new HashMap<String, String>();
        for(String key : map.keySet()) {
            Object valObj = map.get(key);
            retMap.put(key, valObj == null ? "" : valObj.toString());
        }

        return retMap;
    }

}
// :)--