package mobile.factory.util;

import mobile.factory.db.dao.BeanObject;
import mobile.factory.exception.ColumnLengthOverException;
import mobile.factory.exception.FrameException;
import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.lang.reflect.Field;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.*;

/**
 * <pre>
 * 이 클래스는 이전에 DataSet에서 사용하던 Bean 관련 작업을 처리
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2014. 5. 7.
 * @time 오후 6:07:11
 **/
public class BeanUtil {
    private final static Log logger = LogFactory.getLog(BeanUtil.class);

    /**
     * 데이터 길이 체크할 타입
     */
    private static Set<String> checkTypeSet = new HashSet<>() {{
        add("VARCHAR2");
    }};

    /**
     * 빈에 데이터 셋팅시 오류발생시 throws 할지 여부
     */
    private static boolean throwEx = false;

    /**
     * 빈 복사
     *
     * @param dest
     * @param orig
     */
    public static void copyBean(BeanObject dest, BeanObject orig) {
        try {
            BeanUtils.copyProperties(dest, orig);
        } catch (Exception e) {
            logger.error("", e);
        }
    }

    /**
     * 빈 복사
     *
     * @param dest
     * @param origin
     * @param fields
     */
    public static void copyBean(BeanObject dest, BeanObject origin, String[] fields) {
        for (String str : fields) {
            try {
                BeanUtils.setProperty(dest, str, BeanUtils.getProperty(origin, str));
            } catch (Exception e) {
                logger.error("", e);
            }
        }
    }

    /**
     * 맵으로 부터 빈 복사
     *
     * @param bean
     * @param map
     */
    public static void copyBeanFromMap(BeanObject bean, Map<String, ? extends Object> map) {
        try {
            BeanUtils.populate(bean, map);
        } catch (Exception e) {
            logger.error("", e);
        }
    }

    /**
     * 빈에서 셋팅된 데이터를 Map으로 변환
     *
     * @param bean
     * @return
     */
    public static Map<String, String> copyMapFromBean(BeanObject bean) {
        Map<String, String> map = new HashMap<String, String>();
        String[] obj = (String[]) bean.getSetFields();
        for (String item : obj) {
            try {
                if (bean.get(item) instanceof java.util.Date) {
                    map.put(StringUtil.convert2CamelCase(item), new Long(((java.util.Date) bean.get(item)).getTime()).toString());
                } else {
                    map.put(StringUtil.convert2CamelCase(item), BeanUtils.getProperty(bean, StringUtil.convert2CamelCase(item)));
                }

            } catch (Exception e) {
                logger.error("", e);
            }
        }
        return map;
    }

    /**
     * 키값의 크기만큼의 데이터를 빈에 셋팅한 리스트를 반환(빈값 기본 셋팅)
     *
     * @param data
     * @param clazz
     * @param baseKeys
     * @return
     */
    public static List createListOfBean(Map<String, Object> data, Class<? extends BeanObject> clazz, String... baseKeys) {
        return createListOfBean(data, clazz, true, true, baseKeys);
    }

    /**
     * 키값의 크기만큼의 데이터를 빈에 셋팅한 리스트를 반환
     *
     * @param data
     * @param clazz
     * @param isSetEmpty 빈값인 값도 셋팅 여부
     * @param baseKeys
     * @return
     */
    public static List createListOfBean(Map<String, Object> data, Class<? extends BeanObject> clazz, boolean isSetEmpty, String... baseKeys) {
        return createListOfBean(data, clazz, isSetEmpty, isSetEmpty, baseKeys);
    }

    /**
     * 키값의 크기만큼의 데이터를 빈에 셋팅한 리스트를 반환
     *
     * @param data
     * @param clazz
     * @param isSetEmpty       빈값인 값도 셋팅 여부
     * @param isNumberSetEmpty 숫자필드에 값이 "" 일때 셋팅여부
     * @param value
     * @return
     */
    public static List createListOfBean(Map<String, Object> data, Class<? extends BeanObject> clazz, boolean isSetEmpty, boolean isNumberSetEmpty, String... value) {
        List<BeanObject> list = new ArrayList<BeanObject>();

        // String 배열 또는 String 형태로 변환
        String[] baseKeys = value instanceof String[] ? value : new String[]{value.toString()};

        int[] sizeArray = new int[]{};
        for (String item : baseKeys) {
            Object valueObj = data.get(item);
            if (valueObj instanceof String[]) {
                sizeArray = ArrayUtils.add(sizeArray, ArrayUtils.getLength(valueObj));
            }
        }

        int maxLength = 1;
        if (ArrayUtils.getLength(sizeArray) > 0) {
            Arrays.sort(sizeArray);

            int firstIdxVal = sizeArray[0];
            int lastIdxVal = sizeArray[sizeArray.length - 1];

            if (firstIdxVal != lastIdxVal) {
                throw new FrameException("셋팅하려고 하는 배열 크기가 일치하지 않습니다.");
            }

            maxLength = lastIdxVal;
        }

        // baseKeys에 공백이 아닌것만 셋팅

        for (int i = 0; i < maxLength; i++) {
            // 값이 모두 셋팅되어 있는지 체크
            boolean allSet = true;

            for (String item : baseKeys) {
                Object valObj = data.get(item);
                if (valObj != null) {
                    String val = valObj instanceof String[] ? ((String[]) valObj)[i] : valObj.toString();
                    if (StringUtils.isBlank(val)) {
                        allSet = false;
                        break;
                    }
                } else {
                    allSet = false;
                    break;
                }
            }

            if (allSet) {
                try {
                    BeanObject bean = (BeanObject) clazz.newInstance();
                    list.add(fillDataOfBean(data, bean, i, isSetEmpty, isNumberSetEmpty));
                } catch (Exception e) {
                    logger.error("Data populate Error", e);
                }
            }
        }

        validateSetValueLength(list, throwEx);

        return list;
    }

    public static BeanObject fillDataOfBean(Map<String, ? extends Object> data, BeanObject bean) {
        return fillDataOfBean(data, bean, 0, false, false);
    }

    public static BeanObject fillDataOfBean(Map<String, ? extends Object> data, BeanObject bean, boolean isSetEmpty) {
        return fillDataOfBean(data, bean, 0, isSetEmpty, false);
    }

    public static BeanObject fillDataOfBean(Map<String, ? extends Object> data, BeanObject bean, boolean isSetEmpty, boolean isNumberSetEmpty) {
        return fillDataOfBean(data, bean, 0, isSetEmpty, isNumberSetEmpty);
    }

    /**
     * bean에 데이터 셋팅
     *
     * @param data
     * @param bean
     * @param idx
     * @param isSetEmpty
     * @param isNumberSetEmpty
     * @return
     */
    public static BeanObject fillDataOfBean(Map<String, ? extends Object> data, BeanObject bean, int idx, boolean isSetEmpty, boolean isNumberSetEmpty) {
        Map<String, String> tmpMap = new HashMap<String, String>();

        Object valObj = null;
        String value = "";

        Field[] fields = bean.getClass().getDeclaredFields();
        Set<String> numFileds = new HashSet<>();
        Map<String, String> fieldMap = new HashMap<>();

        // 기본값이 0인 컬럼 목록
        for (Field item : fields) {
            String itemName = item.toString();
            String classType = item.getType().toString();

            fieldMap.put(item.getName(), classType);

            if (itemName.startsWith("private") && ("long".equals(classType) || "int".equals(classType) || "float".equals(classType) || "double".equals(classType))) {
                numFileds.add(item.getName());
            }
        }

        for (String key : data.keySet()) {
            valObj = data.get(key);

            if (valObj != null) {
                if (valObj instanceof Date || valObj instanceof Timestamp) {
                    continue;
                }

                if (valObj instanceof String[] && ((String[]) valObj).length > idx) {
                    value = ((String[]) valObj)[idx];
                } else {
                    if (valObj instanceof String[]) {
                        value = ((String[]) valObj)[0];
                    } else if (valObj instanceof Timestamp) {

                    } else {
                        value = valObj.toString();
                    }
                }

                tmpMap.put(key, value);
            }

            // 타입에 상관없이 셋팅하려고 하는 값이 "" 이면 셋팅안함
            if (isSetEmpty == false && StringUtils.isBlank(value)) {
                tmpMap.remove(key);
            }
            // 타입이 number 형이고, 값이 "" 이면 셋팅안함
            if (isNumberSetEmpty == false && numFileds.contains(key) && StringUtils.isBlank(value)) {
                tmpMap.remove(key);
            }
        }

        // 정수형타입에 실수형 데이터(소수점이 포함)를 넣으면 0으로 되는 현상이 있어, 수정함
        for (String key : fieldMap.keySet()) {
            String classType = fieldMap.get(key);
            if (("long".equals(classType) || "int".equals(classType)) && tmpMap.containsKey(key)) {
                String val = tmpMap.get(key);
                if (StringUtils.contains(val, ".")) {
                    val = StringUtils.substringBefore(val, ".");
                    tmpMap.put(key, val);
                }
            }
        }

        try {
            populate(bean, tmpMap);
        } catch (Exception e) {
            logger.error("Data populate Error", e);
        }

        validateSetValueLength(bean, throwEx);

        return bean;
    }

    /**
     * PK항목만 setting한 Bean을 만들어 주는 메소드. 인자로 넘오온 clazz는 반드시 BeanXXX 이어야 한다.
     * colName, Class clazz) 나 createKeyBean(String colName, String colName2,
     * Class clazz) 를 사용할 것.
     *
     * @param keyBean
     * @return
     */
    public static BeanObject fillKeyData(Map<String, Object> data, BeanObject keyBean) {
        try {
            for (String key : keyBean.getPrimaryKeyList()) {
                Object value = data.get(key);
                BeanUtils.setProperty(keyBean, key, value);
            }
        } catch (Exception e) {
            logger.error(" setting Error!!", e);
            throw new FrameException(e.getMessage());
        }

        keyBean.setInputParam(CollectionUtil.toStringMap(data));

        validateSetValueLength(keyBean, throwEx);

        return keyBean;
    }

    public static BeanObject fillKeyData(Map<String, Object> data, String colName, BeanObject keyBean) {
        try {
            Object value = data.get(colName);
            BeanUtils.setProperty(keyBean, colName, value);
        } catch (Exception e) {
            logger.error(colName + " setting Error!!", e);
            throw new FrameException(e.getMessage());
        }

        keyBean.setInputParam(CollectionUtil.toStringMap(data));

        validateSetValueLength(keyBean, throwEx);

        return keyBean;
    }

    public static BeanObject fillKeyData(Map<String, Object> data, String colName, String colName2, BeanObject keyBean) {
        try {
            Object value = data.get(colName);
            BeanUtils.setProperty(keyBean, colName, value);
            Object value2 = data.get(colName2);
            BeanUtils.setProperty(keyBean, colName2, value2);
        } catch (Exception e) {
            logger.error(colName + " setting Error!!", e);
            throw new FrameException(e.getMessage());
        }

        keyBean.setInputParam(CollectionUtil.toStringMap(data));

        validateSetValueLength(keyBean, throwEx);

        return keyBean;
    }

    private static void populate(BeanObject bean, Map<String, String> columnData) throws Exception {
        // Map의 데이터로 poplute를 실행하므로, 셋팅할 항목이 있는것만 처리
        // 약간의 성능보장.. cmd 부분이 셋팅 안되서 적용 안함
//		Map<String, String> populateMap = new HashMap<>();
//		Arrays.stream(bean.getRealFieldArray()).forEach(item ->{
//			if(columnData.containsKey(item)) {
//				populateMap.put(item, columnData.get(item));
//			}
//		});

        BeanUtils.populate(bean, columnData);
        bean.setInputParam(columnData);

        validateSetValueLength(bean);
    }

    /**
     * 속성에 의한 값을 가져옴, 없으면 기본 ""
     *
     * @param bean
     * @param fieldName
     * @return
     */
    public static String getProperty(BeanObject bean, String fieldName) {
        String retVal = "";
        try {
            retVal = BeanUtils.getProperty(bean, fieldName);
        } catch (Exception e) {
            logger.warn("", e);
        }

        return retVal;
    }

    /**
     * 빈에 값 셋팅
     *
     * @param bean
     * @param fieldName
     * @param value
     */
    public static void setProperty(BeanObject bean, String fieldName, Object value) {
        try {
            BeanUtils.setProperty(bean, fieldName, value);
        } catch (Exception e) {
            logger.warn("", e);
        }
    }

    /**
     * 입력된 값 사이즈 체크
     *
     * @param bean
     * @param throwEx true : 오류시 exception, false : 오류내용 반환
     * @return throwEx : false 오류 발생시 오류내용, 정상이면 ""
     * @throws ColumnLengthOverException
     */
    public static String validateSetValueLength(BeanObject bean, boolean throwEx) throws ColumnLengthOverException {
        Map<String, String> inputParam = bean.getInputParam();
        for (String item : bean.getFieldArray()) {
            if (checkTypeSet.contains(bean.getDBColumnType(item)) && bean.isSetField(item)) {
                String value = inputParam.get(item);

                // DB에서 값을 조회하여 셋팅하면 bean에 값이 없더라도 null로 셋팅되므로, null은 없앰
                value = "null".equals(value) ? "" : value;

                int maxSize = bean.getDBColumnSize(item);
                int valueSize = StringUtil.lengthByte(value, "euc-kr");

                int checkValueSize = maxSize <= 200 ? valueSize : (valueSize + (int) (valueSize * 0.1));

                if (checkValueSize > maxSize) {
                    String msg = String.format("최대 입력값이 초과 하였으니 확인해 주세요.\n- 예상항목 : %s, - 최대 글자수 : %d자", StringUtils.defaultString(bean.getDBColumnComment(item), item), maxSize);

                    if (throwEx) {
                        throw new ColumnLengthOverException("590", msg);
                    } else {
                        return msg;
                    }
                }
            }
        }

        return "";
    }

    /**
     * 입력된 값 사이즈 체크
     *
     * @param bean
     * @return throwEx : false 오류 발생시 오류내용, 정상이면 ""
     * @throws ColumnLengthOverException
     */
    public static String validateSetValueLength(BeanObject bean) throws ColumnLengthOverException {
        return validateSetValueLength(bean, true);
    }

    /**
     * 입력된 값 사이즈 체크
     *
     * @param list
     * @param throwEx true : 오류시 exception, false : 오류내용 반환
     * @return throwEx : false 오류 발생시 오류내용, 정상이면 ""
     * @throws ColumnLengthOverException
     */
    public static String validateSetValueLength(List<BeanObject> list, boolean throwEx) throws ColumnLengthOverException {
        String result = "";
        for (BeanObject bean : list) {
            result = validateSetValueLength(bean, throwEx);
            if (StringUtils.isNotBlank(result)) {
                return result;
            }
        }
        return result;
    }

    /**
     * 입력된 값 사이즈 체크(오류시 exception 발생)
     *
     * @param list
     * @return 오류 발생시 Exception, 정상이면 ""
     * @throws ColumnLengthOverException
     */
    public static String validateSetValueLength(List<BeanObject> list) throws ColumnLengthOverException {
        return validateSetValueLength(list, true);
    }
}
// :)--