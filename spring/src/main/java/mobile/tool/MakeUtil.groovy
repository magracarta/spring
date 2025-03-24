package mobile.tool

import org.apache.commons.lang3.StringUtils

/**
 * @author JeongY.Eom
 * @date 2010. 6. 25.
 */
class MakeUtil {
    public static String ROOT_DIR = StringUtils.substringBeforeLast(System.getProperty("user.dir"), '/src/main')
    public static Map<String, String> conf = getConf();
	
	public static final String CHAR_SET = "utf-8";
	
    // 디비와 자바 객체간에 매핑
    static def colTypeMap = [
            "INT"      : "long",
            "INTEGER"  : "long",
            "NUMBER"   : "double",
            "FLOAT"    : "double",
            "CHAR"     : "String",
            "VARCHAR"  : "String",
            "VARCHAR2" : "String",
            "DATE"     : "String",
            "DATETIME" : "java.util.Date",
            "TIMESTAMP": "java.util.Date",
            "INT UNSIGNED": "int",
            "BIGINT UNSIGNED": "long",
			"TIME"     : "java.util.Date" 
    ]

    // 디비와 자바스크립트 객체간에 매핑
    static def colJSTypeMap = [
            "int"           : "int",
			"Integer"		: "int",
            "Float"         : "int",
            "String"        : "string",
            "java.util.Date": "date",
    ]

    /**
     * java 형으로 변환된 것을 js 형태로 변환 colTypeMap 가 추가되면 colJSTypeMap 에도 추가
     * @param type
     * @return
     */
    public static String convertJavaJS(String type) {
        def retType = colJSTypeMap[type]
        if (retType == null) {
            retType = "string"
        }

        return retType;
    }

    /**
     * 환경설정
     * @return
     */
    public static Map<String, String> getConf() {
        return getConf("BeanObject.xml");
    }
	
	/**
	 * 환경설정
	 * @param beanName 읽을명(확장자포함)
	 * @return
	 */
	public static Map<String, String> getConf(String beanName) {
		def conf = new HashMap<String, String>()
		def props = new Properties()

		String readBeanProp = String.format("/%s", beanName)
		
		props.loadFromXML(MakeUtil.class.getResourceAsStream(readBeanProp))
		conf.putAll(new HashMap<String, String>(props))

		this.conf = conf
		return conf;
	}

    public static String toFirstUpper(String str) {
        return toFirstUpper(str, true)
    }

    public static String toFirstUpper(String str, boolean extLower) {
        if (str == null || str.size() == 0) {
            return "";
        }
        return str.substring(0, 1).toUpperCase() + (extLower ? str.substring(1).toLowerCase() : str.substring(1));
    }

    public static String toFirstLower(String str) {
        if (str == null || str.size() == 0) {
            return "";
        }
        return str.substring(0, 1).toLowerCase() + str.substring(1);
    }

    public static String beanFileName(String table) {
        def prefix = "";
        if (table.startsWith("T_") || table.startsWith("V_") == false) {
            prefix = "Bean"
        } else {
            prefix = "VBean"
        }
		table = StringUtils.removeStartIgnoreCase(table, "T_");
		table = StringUtils.removeStartIgnoreCase(table, "V_");

		table = this.convert2CamelCase(table);
		
        String retStr = ROOT_DIR + conf.basePath + "beans/" + prefix + toFirstUpper(table, false) + ".java";

        return retStr;
    }


    public static String getJavaType(String type) {
        def retType = colTypeMap[type]
        if (retType == null) {
            retType = "String"
        }

        return retType;
    }


    public static String makeDaoName(String str) {
        //str = str.toLowerCase();
        str = str.replaceAll("VBean", "v")
        str = str.replaceAll("Bean", "")
		
		/*
        String[] array = str.split("_")
        String retStr = ""
        for (i in 0..array.length - 1) {
            String item = array[i];
            if (i > 0) {
                item = item.substring(0, 1).toUpperCase() + item.substring(1);
            }
            retStr += item;
        }
		*/
        return this.toFirstLower(str) + "Dao";
    }

    public static List<String> getEncryptionFileList() {
        List<String> fileContentList = new ArrayList<String>();
//		new File(ROOT_DIR + "/template/properties/EncryptionInfo.properties").eachLine{ line ->
//			fileContentList.add(line.replaceAll(" ", ""));
//		}
        return fileContentList;
    }
	
	public static String convert2CamelCase(String underScore) {
		// '_' 가 나타나지 않으면 이미 camel case 로 가정함.
		// 단 첫째문자가 대문자이면 camel case 변환 (전체를 소문자로) 처리가
		// 필요하다고 가정함. --> 아래 로직을 수행하면 바뀜
		if (underScore.indexOf('_') < 0
			&& Character.isLowerCase(underScore.charAt(0))) {
			return underScore;
		}
		StringBuilder result = new StringBuilder();
		boolean nextUpper = false;
		int len = underScore.length();
	
		for (int i = 0; i < len; i++) {
			char currentChar = underScore.charAt(i);
			if (currentChar == '_') {
				nextUpper = true;
			} else {
				if (nextUpper) {
					result.append(Character.toUpperCase(currentChar));
					nextUpper = false;
				} else {
					result.append(Character.toLowerCase(currentChar));
				}
			}
		}
		return result.toString();
	}
}
//:)--