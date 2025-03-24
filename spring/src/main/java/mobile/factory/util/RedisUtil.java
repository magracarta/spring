package mobile.factory.util;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * <pre>
 *  이 클래스는 레디스에 데이터 셋팅 및 조회
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2023.02.09
 * @time 09:05
 **/
public class RedisUtil {
    /**
     * 데이터 저장
     *
     * @param redisTemplate
     * @param key
     * @param data
     * @param timeout       저장시간(밀리세컨드)
     */
    public static void set(RedisTemplate<String, Object> redisTemplate, String key, Object data, long timeout) {
        ValueOperations<String, Object> vop = redisTemplate.opsForValue();

        if (timeout > 0) {
            vop.set(key, data, timeout, TimeUnit.MILLISECONDS);
        } else {
            vop.set(key, data);
        }
    }

    /**
     * 데이터 저장
     *
     * @param redisTemplate
     * @param key
     * @param data
     */
    public static void set(RedisTemplate<String, Object> redisTemplate, String key, Object data) {
        set(redisTemplate, key, data, 0);
    }

    /**
     * 데이터 저장
     *
     * @param redisTemplate
     * @param key
     * @param timeout       저장시간(밀리세컨드)
     */
    public static void set(RedisTemplate<String, Object> redisTemplate, String key, long timeout) {
        set(redisTemplate, key, key, timeout);
    }

    /**
     * 데이터 저장
     *
     * @param redisTemplate
     * @param key
     */
    public static void set(RedisTemplate<String, Object> redisTemplate, String key) {
        set(redisTemplate, key, 0);
    }

    /**
     * 레디스에 정보 저장
     *
     * @param redisTemplate
     * @param key           context:key로 저장
     * @param data
     */
    public static void setContext(RedisTemplate<String, Object> redisTemplate, String key, Object data) {
        setContext(redisTemplate, key, data, 0);
    }

    /**
     * 레디스에 정보 저장
     *
     * @param redisTemplate
     * @param key           context:key로 저장
     * @param data
     * @param timeout       저장시간(밀리세컨드)
     */
    public static void setContext(RedisTemplate<String, Object> redisTemplate, String key, Object data, long timeout) {
        set(redisTemplate, String.format("context:%s", key), data, timeout);
    }

    /**
     * 레디스에 정보저장
     *
     * @param redisTemplate
     * @param jobName
     * @param key
     * @param data
     * @param timeout       저장시간(밀리세컨드)
     */
    public static void setContext(RedisTemplate<String, Object> redisTemplate, String jobName, String key, Object data, long timeout) {
        String newKey = StringUtils.isNotBlank(jobName) ? String.format("%s:%s", jobName, key) : key;

        setContext(redisTemplate, newKey, data, timeout);
    }

    /**
     * 레디스에 정보저장
     *
     * @param redisTemplate
     * @param jobName
     * @param key
     * @param data
     */
    public static void setContext(RedisTemplate<String, Object> redisTemplate, String jobName, String key, Object data) {
        setContext(redisTemplate, jobName, key, data, 0);
    }

    /**
     * 맵 조회, 리스트가 요소이면 0번째 반환
     *
     * @param redisTemplate
     * @param key
     * @return 없으면..
     */
    public static Map getContextMap(RedisTemplate<String, Object> redisTemplate, String key) {
        return getMap(redisTemplate, String.format("context:%s", key));
    }

    /**
     * 셋 조회, 리스트가 요소이면 0번째 반환
     *
     * @param redisTemplate
     * @param key
     * @return 없으면..
     */
    public static Set getContextSet(RedisTemplate<String, Object> redisTemplate, String key) {
        return getSet(redisTemplate, String.format("context:%s", key));
    }

    /**
     * 리스트 조회, 한행이면 리스트 생성후 반환
     *
     * @param redisTemplate
     * @param key
     * @return
     */
    public static List getContextList(RedisTemplate<String, Object> redisTemplate, String key) {
        return getList(redisTemplate, String.format("context:%s", key));
    }

    /**
     * 맵 조회, 리스트가 요소이면 0번째 반환
     *
     * @param redisTemplate
     * @param jobName
     * @param key
     * @return
     */
    public static Map getContextMap(RedisTemplate<String, Object> redisTemplate, String jobName, String key) {
        String newKey = StringUtils.isNotBlank(jobName) ? String.format("%s:%s", jobName, key) : key;

        return getContextMap(redisTemplate, newKey);
    }

    /**
     * 셋 조회, 리스트가 요소이면 0번째 반환
     *
     * @param redisTemplate
     * @param jobName
     * @param key
     * @return
     */
    public static Set getContextSet(RedisTemplate<String, Object> redisTemplate, String jobName, String key) {
        String newKey = StringUtils.isNotBlank(jobName) ? String.format("%s:%s", jobName, key) : key;

        return getContextSet(redisTemplate, newKey);
    }

    /**
     * 리스트 조회, 한행이면 리스트 생성후 반환
     *
     * @param redisTemplate
     * @param jobName
     * @param key
     * @return
     */
    public static List getContextList(RedisTemplate<String, Object> redisTemplate, String jobName, String key) {
        String newKey = StringUtils.isNotBlank(jobName) ? String.format("%s:%s", jobName, key) : key;

        return getContextList(redisTemplate, newKey);
    }

    /**
     * 리스트<맵>이면 0번째, 맵이면 맵, 아니면 null
     *
     * @param redisTemplate
     * @param key
     * @return
     */
    public static Map getMap(RedisTemplate<String, Object> redisTemplate, String key) {
        Object obj = redisTemplate.opsForValue().get(key);

        if (obj == null) {
            return null;
        }

        // list 일때
        if (obj instanceof List) {
            Object firstRow = ((List<?>) obj).get(0);
            if (firstRow instanceof Map) {
                return (Map) firstRow;
            } else {
                return null;
            }
        }

        // map 일때
        if (obj instanceof Map) {
            return (Map) obj;
        }

        return null;
    }

    /**
     * 키 확인
     * @param redisTemplate
     * @param key
     * @return
     */
    public static boolean existsKey(RedisTemplate<String, Object> redisTemplate, String key) {
        Object obj = get(redisTemplate, key);

        return obj == null ? false : true;
    }

    /**
     * 키 조회
     * @param redisTemplate
     * @param key
     * @return
     */
    public static Object get(RedisTemplate<String, Object> redisTemplate, String key) {
        Object obj = redisTemplate.opsForValue().get(key);

        return obj;
    }

    /**
     * 리스트면 바로 반환, 하나면 리스트로 추가후 반환, 없으면 null
     *
     * @param redisTemplate
     * @param key
     * @return
     */
    public static List getList(RedisTemplate<String, Object> redisTemplate, String key) {
        Object obj = redisTemplate.opsForValue().get(key);

        if (obj == null) {
            return null;
        }

        // list 일때
        if (obj instanceof List) {
            return (List) obj;
        }

        // map 일때
        if (obj instanceof Map) {
            List list = new ArrayList<>();
            list.add(obj);

            return list;
        }

        return null;
    }

    /**
     * 리스트<셋>이면 0번째, 셋이면 셋, 아니면 null
     *
     * @param redisTemplate
     * @param key
     * @return
     */
    public static Set getSet(RedisTemplate<String, Object> redisTemplate, String key) {
        Object obj = redisTemplate.opsForValue().get(key);

        if (obj == null) {
            return null;
        }

        // list 일때
        if (obj instanceof List) {
            Object firstRow = ((List<?>) obj).get(0);
            if (firstRow instanceof Set) {
                return (Set) firstRow;
            } else {
                return null;
            }
        }

        // Set 일때
        if (obj instanceof Set) {
            return (Set) obj;
        }

        return null;
    }

    /**
     * 세션 member 전체 조회
     *
     * @param redisTemplate
     * @param userName      (id)
     * @return the set
     */
    public static Set getSessionMemberSet(RedisTemplate<String, Object> redisTemplate, String userName) {
        String newKey = String.format("spring:session:index:org.springframework.session.FindByIndexNameSessionRepository.PRINCIPAL_NAME_INDEX_NAME:%s", userName);

        return getMemberSet(redisTemplate, newKey);
    }

    /**
     * key(Set type) member 전체 조회
     *
     * @param redisTemplate
     * @param key
     * @return the set
     */
    public static Set getMemberSet(RedisTemplate<String, Object> redisTemplate, String key) {
        Object obj = redisTemplate.opsForSet().members(key);

        if (obj == null) {
            return null;
        }

        if (obj instanceof Set) {
            return (Set) obj;
        }

        return null;
    }

    /**
     * 레디스 세션 데이터 삭제
     *
     * @param redisTemplate
     * @param sessionId
     * @return
     */
    public static void deleteSession(RedisTemplate<String, Object> redisTemplate, String sessionId) {
        delete(redisTemplate, String.format("spring:session:sessions:expires:%s", sessionId));
        delete(redisTemplate, String.format("spring:session:sessions:%s", sessionId));
    }

    /**
     * 레디스 데이터 삭제
     *
     * @param redisTemplate
     * @param key
     * @return
     */
    public static void delete(RedisTemplate<String, Object> redisTemplate, String key) {
        redisTemplate.delete(key);
    }

    /**
     * 레디스 value 존재 확인(Set일때만 유효)
     *
     * @param redisTemplate
     * @param key
     * @param value
     * @return the boolean
     */
    public static boolean redisExistsValue(RedisTemplate<String, Object> redisTemplate, String key, String value) {
        Set<String> set = getContextSet(redisTemplate, key);
        if (set == null) {
            return false;
        }

        return set.contains(value);
    }

    /**
     * 레디스 value 추가
     *
     * @param redisTemplate
     * @param key
     * @param value
     */
    public static void redisAddValue(RedisTemplate<String, Object> redisTemplate, String key, String value) {
        Set<String> set = getContextSet(redisTemplate, key);
        set = set == null ? new HashSet<>() : set;

        set.add(value);

        setContext(redisTemplate, key, set);
    }

    /**
     * 레디스 value 삭제
     *
     * @param redisTemplate
     * @param key
     * @param value
     */
    public static void redisRemoveValue(RedisTemplate<String, Object> redisTemplate, String key, String value) {
        Set<String> set = getContextSet(redisTemplate, key);
        set = set == null ? new HashSet<>() : set;

        set.remove(value);

        setContext(redisTemplate, key, set);
    }
} //:)--
