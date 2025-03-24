package test;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
//import net.minidev.json.writer.BeansMapper.Bean;

/**
 * collect 객체를 가공하기 위한 클래스
 * 
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 27
 */
public class CollectionUtil {	/**
	 * <pre>
	 * 리스트 요소가 맵으로 왔을때 keyString 으로 정의된 key로
	 * 동일한 리스트 요소에 맵으로 넣는다.
	 * 주의: 배열의 요소는 정렬이 되어 있어야 한다
	 * <p/>
	 * list[0] = hashmap{aaa=111, bbb=abc}
	 * list[1] = hashmap{aaa=111, bbb=def}
	 * list[2] = hashmap{aaa=222, bbb=gif}
	 * <p/>
	 * ==> map : 111 -> list[0] = {hashmap{aaa=111, bbb=abc}
	 *                  list[1] = {hashmap{aaa=111, bbb=def}
	 *           222 -> list[0] = {hashmap{aaa=222, bbb=gif}
	 * </pre>
	 * 
	 * @param listMap
	 * @param keyString
	 * @return 맵
	 */
	public static Map<String, List<Map<String, Object>>> mapListToMap(List<Map<String, Object>> listMap, String keyString) {
		return mapListToMap(listMap, keyString, null);
	}
	
	/**
     * <pre>
	 * 리스트 요소가 맵으로 왔을때 keyString 으로 정의된 key로
	 * 최상위 요소만 맵으로 변환하여, 반환
	 * </pre>
	 * @param listMap
	 * @param keyString
	 * @return 맵
	 */
	public static Map<String, Map<String, Object>> mapListToOneMap(List<Map<String, Object>> listMap, String keyString) {
		Map<String, Map<String, Object>> map = new LinkedHashMap<>();
		
		 Map<String, List<Map<String, Object>>> mapList = mapListToMap(listMap, keyString);
		 for(String key : mapList.keySet()) {
			 map.put(key, mapList.get(key).get(0));
		 }
		
		return map;
	}

	/**
	 * <pre>
	 * 리스트 요소가 맵으로 왔을때 keyString 으로 정의된 key로
	 * 동일한 리스트 요소에 맵으로 넣는다.
	 * 주의: 배열의 요소는 정렬이 되어 있어야 한다.
	 * <p/>
	 * list[0] = hashmap{aaa=111, bbb=abc}
	 * list[1] = hashmap{aaa=111, bbb=def}
	 * list[2] = hashmap{aaa=222, bbb=gif}
	 * <p/>
	 * ==> map : 111 -> list[0] = {hashmap{aaa=111, bbb=abc}
	 *                  list[1] = {hashmap{aaa=111, bbb=def}
	 *           222 -> list[0] = {hashmap{aaa=222, bbb=gif}
	 * </pre>
	 * 
	 * @param listMap
	 * @param keyString
	 * @param 반환맵
	 * @return 맵
	 */
	public static Map<String, List<Map<String, Object>>> mapListToMap(List<Map<String, Object>> listMap, String keyString, Map<String, List<Map<String, Object>>> retMap) {
		boolean isFirst = true;
		Map<String, List<Map<String, Object>>> data = retMap == null ? new LinkedHashMap<String, List<Map<String, Object>>>() : retMap;
		String key = "";

		if (listMap == null || listMap.size() == 0) {
			return data;
		}

		List<Map<String, Object>> rowList = null;
		for (Iterator<Map<String, Object>> it = listMap.iterator(); it.hasNext();) {
			Map<String, Object> row = it.next();
			String rowKeyValue = row.get(keyString.toLowerCase()).toString();
			if (isFirst || !key.equals(rowKeyValue)) {
				if (!isFirst) {
					data.put(key, rowList);
				}
				rowList = new ArrayList<Map<String, Object>>();
				rowList.add(row);

				isFirst = false;
			} else {
				rowList.add(row);
			}
			key = rowKeyValue;
		}
		data.put(key, rowList);
		return data;
	}
	
	/**
	 * <pre>
	 * 리스트의 요소가 맵으로 왔을때 keyString 으로 정의된 key의 value로
	 * 배열을 생성한다
	 * <p/>
	 * list[0] = hashmap{aaa=111, bbb=abc}
	 * list[1] = hashmap{aaa=111, bbb=def}
	 * list[2] = hashmap{aaa=222, bbb=gif}
	 * <p/>
	 * ==> array : {[adb],[def],[gif]}
	 * </pre>
	 * 
	 * @param listMap
	 * @param keyString
	 * @return array
	 */
	public static String[] mapListToArray(List listMap, String keyString) {
		if (listMap == null) {
			return new String[0];
		}

		String[] retArray = new String[listMap.size()];

		int i = 0;
		for (Iterator it = listMap.iterator(); it.hasNext();) {
			Map val = (Map) it.next();
			if(val.containsKey(keyString)) {
				String keyName = keyString.toLowerCase();
				Object valObj = val.get(keyName);
				
				retArray[i++] = valObj == null ? "" : valObj.toString();
			}
		}
		return retArray;
	}

	/**
	 * 배열요소중 "" 삭제
	 * 
	 * @param array
	 * @return 배열
	 */
	public static String[] removeEmptyElement(String[] array) {
		if (array == null || ArrayUtils.isEmpty(array)) {
			return new String[0];
		}
		Arrays.sort(array);
		int idx = 0;
		for (int i = 0, n = array.length; i < n; i++) {
			if (StringUtils.isEmpty(array[i])) {
				idx++;
			}
		}
		String[] retArray = (String[]) ArrayUtils.subarray(array, idx, array.length);

		return retArray;
	}

	/**
	 * bean 데이터를 Map으로 변환시킨다
	 * 
	 * @param bean
	 * @return
	 */
//	public static Map<String, String> beanToMap(BeanObject bean) {
//		Map<String, String> map = new HashMap<String, String>();
//
//		String[] field = bean.getFieldArray();
//		for (String item : field) {
//			try {
//				String value = StringUtils.defaultString(BeanUtils.getProperty(bean, item));
//
//				map.put(item, value);
//			} catch (Exception e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//		}
//		return map;
//	}

	/**
	 * 데이터 값이 null을 ""으로변환 시킨다.
	 * 
	 * @param map
	 * @return
	 */
	public static Map<String, String> null2Blank(Map<String, Object> map) {
		if (map == null) {
			return null;
		}
		Map<String, String> retMap = new HashMap<String, String>();

		for (String item : map.keySet()) {
			Object val = map.get(item);

			String value = val == null ? "" : val.toString();
			retMap.put(item, value);
		}
		return retMap;
	}

	/**
	 * 문자 리스트를 배열로 변환한다.
	 * 
	 * @param list
	 * @return
	 */
	public static String[] listToStringArray(List<String> list) {
		String[] array = new String[list.size()];

		int i = 0;
		for (String row : list) {
			array[i++] = row;
		}

		return array;
	}

	/**
	 * 리스트 중복제거
	 * 
	 * @param list
	 * @return
	 */
	public static List<String> removeDupList(List<String> list) {
		List<String> arrDeleteNo = new ArrayList<String>(new HashSet<String>(list));
		return arrDeleteNo;
	}

	/**
	 * get 형식으로 변환, 기본 euc-kr 인코딩
	 * 
	 * @param map
	 * @param keys
	 * @return aa=1&bb=c
	 */
//	public static String toGetString(Map<String, String> map, String[] keys, String encoding) {
//		List<String> list = new ArrayList<>();
//
//		if (ArrayUtils.isEmpty(keys)) {
//			keys = map.keySet().toArray(new String[] {});
//		}
//
//		for (String key : keys) {
//			list.add(String.format("%s=%s", key, HttpUtil.urlEncode(map.get(key), encoding)));
//		}
//
//		return StringUtils.join(list.toArray(new String[]{}), "&");
//	}

	/**
	 * 요소를 모두 get 형식으로 변환, 값은 모두 euc-kr 인코딩
	 * 
	 * @param map
	 * @return
	 */
//	public static String toGetString(Map<String, String> map, String encoding) {
//		return toGetString(map, null, encoding);
//	}
	
	/**
	 * 맵 합치기
	 * 
	 * @param origin
	 * @param dest
	 * @return
	 */
	public static Map<String, Object> merge(Map<String, Object> origin, Map<String, Object> dest) {
		if (dest == null || dest.isEmpty()) {
			return origin;
		}

		if (origin == null) {
			origin = new HashMap<String, Object>();
		}

		for (String key : dest.keySet()) {
			origin.put(key, dest.get(key));
		}
		return origin;
	}
	
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
	
	/**
	 * <String, Object> 타입으로 변환
	 * @param map
	 * @return
	 */
	public static Map<String, Object> toObjectMap(Map<String, String> map) {
		if(map == null) {
			return null;
		}

		Map<String, Object> retMap = new HashMap<>();
		for(String key : map.keySet()) {
			retMap.put(key, map.get(key).toString());
		}

		return retMap;
	}
	
	/**
	 * List<Map<String, String>> 으로 변환
	 * @param list
	 * @return
	 */
	public static List<Map<String, String>> listToStringMap(List<Map<String, Object>> list) {
		if(list == null) {
			return null;
		}
		List<Map<String, String>> retList = new ArrayList<Map<String,String>>();
		for(Map<String, Object> row : list) {
			retList.add(toStringMap(row));
		}
		
		return retList;
	}
	
	/**
	 * Map 으로 구성된 리스트를 특정키로 하는 List로 구성
	 * 
	 * @param list
	 *            Data
	 * @param key
	 *            만드는 키
	 * @return
	 */
	public static List<String> toStringList(List<Map<String, Object>> list, String key) {
		if(list == null) {
			return null;
		}
		List<String> retList = new ArrayList<>();
		for (Map<String, ?> row : list) {
			String val = row.containsKey(key) ? row.get(key).toString() : "";
			retList.add(val);
		}
		return retList;
	}

	/**
	 * 원하는 필드만 재가공
	 * @param list
	 * @param addIfNotExists 항목이 없으면 "" 로 요소를 추가함
	 * @param field
	 * @return
	 */
	public static List<Map<String, Object>> keyList(List<Map<String, Object>> list, boolean addIfNotExists, String... field) {
		if(list == null) {
			return null;
		}

		List<Map<String, Object>> retList = new ArrayList<Map<String, Object>>();

		for (Map<String, Object> item : list) {
			retList.add(keyMap(item, addIfNotExists, field));
		}

		return retList;
	}
	
	/**
	 * 리스트를 맵으로 가공, 리스트로 된 요소는 맵의 String[]로 존재
	 * @param list
	 * @return list.size > 1 요소는배열, list.size = 1 요소는 문자
	 */
	public static Map<String, ? extends Object> listMapToMap(List<Map<String, Object>> list) {
		if(list == null) {
			return null;
		}

		if (list.size() == 1) {
			return toStringMap(list.get(0));
		}

		Map<String, Object> map = new HashMap<>();
		for (Map<String, Object> row : list) {
			for (String item : row.keySet()) {
				Object val = row.get(item);
				String[] mapValArray = map.containsKey(item) ? (String[]) map.get(item) : new String[] {};

				mapValArray = ArrayUtils.add(mapValArray, val == null ? "" : val.toString());

				map.put(item, mapValArray);
			}
		}

		return map;
	}
	
	/**
	 * 원하는 필드만 재가공 (없는 항목은 무시)
	 * @param list
	 * @param field
	 * @return
	 */
	public static List<Map<String, Object>> keyList(List<Map<String, Object>> list, String... field) {
		return keyList(list, false, field);
	}

	/**
	 * 원하는 필드만 재가공
	 * @param map 
	 * @param addIfNotExists 항목이 없으면 "" 로 요소를 추가함
	 * @param field
	 * @return
	 */
	public static Map<String, Object> keyMap(Map<String, Object> map, boolean addIfNotExists, String... field) {
		Map<String, Object> retMap = new HashMap<>();
		
		if(map == null) {
			return retMap;
		}
		
		for (String item : field) {
			if (map.containsKey(item)) {
				retMap.put(item, map.get(item));
			} else {
				if (addIfNotExists) {
					retMap.put(item, "");
				}
			}
		}
		return retMap;
	}

	/**
	 * 배열을 리스트로 변환
	 * @param strings
	 * @return
	 */
	public static List<String> toStringList(String... strings) {
		if (strings == null) {
			return null;
		}

		List<String> list = new ArrayList<>();
		for (String item : strings) {
			list.add(item);
		}

		return list;
	}
	
	/**
	 * 맵에 key 가 대문자인것을 소문자로 변경한다. 
	 * @param map
	 * @return
	 */
	public static Map convertLowerMapKey(Map map) {
		return convertMapKey(map, true);
	}
	
	public static Map convertUpperMapKey(Map map) {
		return convertMapKey(map, false);
	}
	
	/**
	 * 맵의 Key 변환
	 * @param map
	 * @param isLower 소문자 변환 여부
	 * @return
	 */
	public static Map convertMapKey(Map map, boolean isLower) {
		if(map == null) {
			return null;
		}
		Map retMap = new HashMap();
		Iterator it = map.keySet().iterator();

		while (it.hasNext()) {
			String key = (String) it.next();
			
			String convertKey = isLower ? key.toLowerCase() : key.toUpperCase();
			retMap.put(convertKey, map.get(key));
		}
		return retMap;
	}
	
	/**
	 * 리스트에 맵 추가(단, 리스트맵과 추가하려는 맵의 요소는 같아야함) 동일한 값이 있으면 대치 안함
	 * 
	 * @param list
	 *            리스트
	 * @param map
	 *            맵
	 * @param keyStr
	 *            비교할 키
	 * @return
	 */
	public static List<Map<String, Object>> add(List<Map<String, Object>> list, Map<String, Object> map, String keyStr) {
		return add(list, map, keyStr, false);
	}
	
	/**
	 * 리스트에 맵 추가(단, 리스트맵과 추가하려는 맵의 요소는 같아야함)
	 * 
	 * @param list
	 *            리스트
	 * @param map
	 *            맵
	 * @param keyStr
	 *            비교할 키
	 * @param replace
	 *            동일한 키가 있으면 대치 여부
	 * @return
	 */
	public static List<Map<String, Object>> add(List<Map<String, Object>> list, Map<String, Object> map, String keyStr, boolean replace) {
		if(list == null || list.isEmpty() || map == null || map.isEmpty()) {
			return list;
		}
		
		if(map.containsKey(keyStr) == false) {
			return list;
		}
		
		// 맵의 key 요소 체크
		Map<String, Object> firstMap = list.get(0);
		int keyCount = firstMap.keySet().size();
		int matchCount = 0;
		boolean isSame = false;
		
		for (String key : firstMap.keySet()) {
			matchCount += map.keySet().contains(key) ? 1 : 0;
			
			if (map.keySet().contains(key) && key.equals(keyStr)) {
				String originValue = firstMap.get(key).toString();
				String compareValue = map.get(key).toString();

				isSame = originValue.equals(compareValue);
			}
		}
		
		if(keyCount != matchCount) {
			return list;
		}
		
		// 동일한 값이 없거나, 있어도 교체여부이면 기존에 추가
		if(isSame == false || replace) {
			list.add(map);
		}
		
		return list;
	}
	
	/**
	 * 맵 생성
	 * 
	 * @param matchArray
	 *            [키1, 값1, 키2, 값2...] 으로 매핑된 맵, 크기가 짝수여야 함
	 * @return 생성 조건 맞지 않으면 빈 맵 반환
	 */
	public static Map<String, Object> createMap(String... matchArray) {
		Map<String, Object> map = new HashMap<>();
		if (matchArray.length > 0 && matchArray.length % 2 == 0) {
			for (int i = 0, n = matchArray.length; i < n; i += 2) {
				map.put(matchArray[i], matchArray[i + 1]);
			}
		}
		return map;
	}

	/**
	 * 키로구성되는 맵을 변환
	 * 
	 * @param map
	 *            대상맵
	 * @param containKey
	 *            생성할 키, 키에 해당하는 값이 없으면 null
	 * @return
	 */
	public static Map<String, Object> convertMap(Map<String, Object> map, String... containKey) {
		Map<String, Object> retMap = new HashMap<>();
		for (String key : containKey) {
			retMap.put(key, map.get(key));
		}

		return retMap;
	}

	/**
	 * 키로구성되는 리스트를 변환
	 * 
	 * @param list
	 *            대상 리스트
	 * @param containKey
	 *            생성할 키, 키에 해당하는 값이 없으면 null
	 * @return
	 */
	public static List<Map<String, Object>> convertList(List<Map<String, Object>> list, String... containKey) {
		List<Map<String, Object>> retList = new ArrayList<>();
		for (Map<String, Object> bean : list) {
			retList.add(convertMap(bean, containKey));
		}

		return retList;
	}
	
	/**
	 * <dt><span class="strong">주의! 맵 안에 같은 키가 있으면 덮어쓰므로, 사라질 수 있음.</span></dt> 
	 * <dt><span class="strong">맵을 복사할때 순서를 잘 생각해서 사용 필요</span></dt>
	 * 맵을 복사
	 * 
	 * @param originMap
	 *            원본맵
	 * @param nameMap
	 *            원본맵에 키를 값의 새로운 키로 변경함. qty : newqty => originMap.qty ->
	 *            originMap.newqty 로 이름이 변경됨
	 * @return
	 */
	public static Map<String, Object> copyMap(Map<String, Object> originMap, Map<String, String> nameMap) {
		Map<String, Object> retMap = new HashMap<>(originMap);

		if (nameMap != null && nameMap.isEmpty() == false) {
			for (String key : nameMap.keySet()) {
				if (retMap.containsKey(key)) {
					String newName = nameMap.get(key);
					retMap.put(newName, retMap.get(key));
					retMap.remove(key);
				}
			}
		}

		return retMap;
	}
	
	/**
	 * 맵에 들에 있는 모든 키에 prefix를 붙여서 맵을 반환
	 * @param originMap 원본맵
	 * @param prefix 붙은 맵
	 * @return
	 */
	public static Map<String, Object> addPrefixKey(Map<String, Object> originMap, String prefix) {
		if (originMap == null) {
			return null;
		}

		Map<String, Object> result = new HashMap<String, Object>();
		for (String key : originMap.keySet()) {
			String newKey = String.format("%s%s", prefix, key);

			result.put(newKey, originMap.get(key));
		}

		return result;
	}
	
	/**
	 * 리스트 맵에 들에 있는 모든 키에 prefix를 붙여서 리스트 맵을 반환
	 * 
	 * @param originMapList
	 *            원본맵
	 * @param prefix
	 *            붙은 맵
	 * @return
	 */
	public static List<Map<String, Object>> addPrefixMapList(List<Map<String, Object>> originMapList, String prefix) {
		List<Map<String, Object>> list = new ArrayList<>();
		
		for (Map<String, Object> map : originMapList) {
			list.add(addPrefixKey(map, prefix));
		}
		
		return list;
	}
	
	/**
	 * 구분자로 리스트 생성
	 * @param str
	 * @param delimiter 구분자
	 * @param trim 각항목 트림여부
	 * @return
	 */
	public static List<String> convertList(String str, String delimiter, boolean trim) {
		List<String> list = new ArrayList<>();
		String[] strArray  = str.split(delimiter);
		
		for(String item : strArray) {
			list.add(trim ? item.trim() : item);
		}
		
		return list;
	}
	
	/**
	 * 구분자로 묶인 문자 반환
	 * @param list MB12, MB34
	 * @param delimiter >
	 * @return MB12 > MB34
	 */
	public static String convertString(List<String> list, String delimiter) {
		StringBuilder sb = new StringBuilder();
		for(String item : list) {
			sb.append(String.format("%s%s", item, delimiter));
		}
		
		return sb.length() > 0 ? StringUtils.removeEnd(sb.toString(), delimiter) : "";
	}
	
	/**
	 * 리스트를 사이즈만큼 그룹핑
	 * ex) [1,2,3,4,5,6] 을 2사이즈로 그루핑하면 [[1,2], [3,4], [5,6]]
	 * @param inputList
	 * @param size
	 * @return 그룹핑된 리스트
	 */
	public static <T> Collection<List<T>> partitionBasedOnSize(List<T> inputList, int size) {
        final AtomicInteger counter = new AtomicInteger(0);
        return inputList.stream().collect(Collectors.groupingBy(s -> counter.getAndIncrement()/size)).values();
    }

	/**
	 * 중복없는 배열생성
	 * @param obj
	 * @return
	 */
	public static String[] unique(String[] obj) {
		if(ArrayUtils.isEmpty(obj)) {
			return obj;
		}

		Set<String> set = new LinkedHashSet<>();
		for(String item : obj) {
			if(StringUtils.isNotBlank(item)) {
				set.add(item);
			}
		}
		return set.toArray(new String[]{});
 	}
}
// :)--