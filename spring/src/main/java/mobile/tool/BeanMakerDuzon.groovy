package mobile.tool

import groovy.sql.Sql
import groovy.text.SimpleTemplateEngine
import mobile.factory.db.dao.DBTableDao
import mobile.factory.util.CollectionUtil

import org.apache.commons.lang3.StringUtils

def COL_NAME = 4;
def COL_TYPE = 6;
def COL_SIZE = 7;
def DECIMAL_DIGITS = 9;
def REMARKS = 12;
def TABLE_TYPE = 4;
def TABLE_NAME = 3;

def rootDir = MakeUtil.ROOT_DIR
def engine = new SimpleTemplateEngine()

// 환경설정 파일 로딩
def conf = MakeUtil.getConf("BeanObjectDuzon.xml")

def template = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/BeanObject.template"), MakeUtil.CHAR_SET))
def daoTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/BeanDaoConfigDuzon.template"), MakeUtil.CHAR_SET))
def daoConfigTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/DaoConfigService.template"), MakeUtil.CHAR_SET))
def dbJsTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/db.column.template"), MakeUtil.CHAR_SET))

def colSizeMap = new HashMap<String, String>();
def colCommentMap = new HashMap<String, String>();
def colTypeMap = new HashMap<String, String>();
def colTypeMapAll = new HashMap<String, String>();
def colDefaultMapAll = new HashMap<String, String>();
def colListAll = new ArrayList<String>()
def pkListAll = new ArrayList<String>()
def encryptColumnList = new ArrayList<String>()			// 암호화 컬럼=> 테이블명.컬럼명
def javaColTypeMapAll = new HashMap<String, String>();

def tableNames = new ArrayList<String>()

// 테이블명 추출
def sql = Sql.newInstance(conf.url, conf.id, conf.passwd, conf.driverClassName)
def conn = sql.getConnection()
def meta = conn.getMetaData()
def rs = meta.getTables(null, 'dbo', '%', null)	// mssql은 dbo 로 검색해야함.

while(rs.next()) {
	def type = rs.getString(TABLE_TYPE)
	if ( type.equals("TABLE") || type.equals("BASE TABLE") || type.equals("VIEW") ) {
		// 테이블 정보 셋팅
		def table = rs.getString(TABLE_NAME)
		tableNames.add(table)
	}
}

def extTable = StringUtils.split(conf.exclusionTable, ",")
def incTable = StringUtils.split(conf.inclusionTable, ",")
def tableNameCheck = StringUtils.defaultIfBlank(conf.tableNameCheck, "Y")
def columnComment = StringUtils.split(conf.columnComment, "#")
def defaultValue = StringUtils.split(conf.defaultValue, "#")
def encryptColumn = StringUtils.split(conf.encryptColumn, "#")

def daoPackageName = conf.basePackageName
def beanPackageName = daoPackageName + '.beans'	// bean 생성 packageName
def daoPath = rootDir + conf.basePath
def beanPath = daoPath + 'beans/'

// 컬럼 defaultvalue
if(defaultValue != null && defaultValue.length > 0) {
	colDefaultMapAll.clear();
	for(String item : defaultValue) {
		String[] row = StringUtils.split(item, "=");
		colDefaultMapAll.put(row[0], row[1]);
	}
}

// 암호화컬럼
if(encryptColumn != null && encryptColumn.length > 0) {
	for(String item : encryptColumn) {
		encryptColumnList.add(item.toUpperCase())
	}
}

// 오라클 컬럼 코맨트는 별도로 조회하여 저장함
def dbOracleCommentMap = makeOracleCommentMap(sql, conf)

def currentDate = mobile.factory.util.DateUtil.getCurrentDate("yyyy-MM-dd")
def currentTime = mobile.factory.util.DateUtil.getCurrentDate("HH:mm:ss")
tableNames.each { table ->
	// 테이블명 체크
	if("Y".equals(tableNameCheck)) {
		if(table.startsWith("T_") == false && table.startsWith("V_") == false) {
			return
		}
	}
	// 제외할 테이블 체크
	if(extTable.contains(table)) {
		return
	}
	// 포함할 테이블명이 있으면 해당테이블만, 비었으면 모두 대상
	if(incTable.length > 0 && incTable.contains(table) == false) {
		return
	}

	def pkList = new ArrayList<String>()
	def typeMap = new HashMap<String, String>()
	def sizeMap = new HashMap<String, String>()
	def commentMap = new HashMap<String, String>()
	def colList = new ArrayList<String>()
	def javaColTypeMap = new HashMap<String, String>();
	def tableRs = meta.getColumns( null, 'dbo', table, '%' );
	def colName = "";
	def colType = "";
	def colSize = "";
	def colComment = "";
	while(tableRs.next()) {
		colName = tableRs.getString(COL_NAME).toLowerCase()
		colType = tableRs.getString(COL_TYPE).toUpperCase()
		colSize = tableRs.getString(COL_SIZE)
		colComment = StringUtils.defaultString( StringUtils.trim(tableRs.getString(REMARKS)))
		if(StringUtils.isBlank(colComment)) {
			String key = String.format('%s.%s', table.toLowerCase(), colName)
			colComment = StringUtils.defaultString(dbOracleCommentMap.get(key))
		}
		// Oracle의 NUMBER type은 (3,2)와 같이 실수에도 사용하므로 소수점 이하가
		// 있는지 채크해서 없으면( "0"이면) INTEGER 타입으로 간주한다.
		// 가끔 digist가 null 인경우도 생긴다.
		if (colType.equals("NUMBER")) {
			def digits = tableRs.getString(DECIMAL_DIGITS)
			if (digits == null || (digits != null && digits.equals("0"))) {
				colType = "INTEGER"
			}
		}
		
		colList.add(colName)
		typeMap.put(colName, colType)
		sizeMap.put(colName, colSize)
		commentMap.put(colName, colComment)
		javaColTypeMap.put(colName, MakeUtil.getJavaType(colType))
		// 디비정보를 모두 모으기 위한 작업.
		colTypeMap.put(colName, MakeUtil.getJavaType(colType))
		
		// 컬럼 사이즈가 큰거를 입력
		if(colSizeMap.containsKey(colName) == false) {
			colSizeMap.put(colName, colSize)
		} else {
			int mapColSize = Integer.parseInt(colSizeMap.get(colName))
			if(mapColSize < Integer.parseInt(colSize)) {
				colSizeMap.put(colName, colSize)
			}
		}
		colCommentMap.put(colName, colComment)
	}
	def pkRs = meta.getPrimaryKeys(null, conf.id.toUpperCase(), table)
	while(pkRs.next()) {
		colName = pkRs.getString(COL_NAME).toLowerCase()
		pkList.add(colName);
	}
	
	def defaultMap = new HashMap<String, String>();
	for(String col : colList) {
		String findKey = table.toLowerCase() + "." + col
		defaultMap.put(col, colDefaultMapAll.containsKey(findKey) ? colDefaultMapAll.get(findKey) : "")
	}
	
	def tableName = table;
	def binding = [
		tableName : tableName,
		pkList : pkList,
		colList : colList,
		typeMap : typeMap,
		sizeMap : sizeMap,
		commentMap : commentMap,
		javaColTypeMap : javaColTypeMap,
		defaultMap : defaultMap,
		currentDate : currentDate,
		currentTime : currentTime,
		encryptColumnList : encryptColumnList
	]
	//###############################################################################
	// bean create
	//###############################################################################
	def fileName = MakeUtil.beanFileName(table)
	
	FileOperator.createDirIfNotExist(fileName);
	dir = fileName.split("/")
	def javaName =  dir[dir.length - 1].replaceAll(".java", "");
	binding.put('javaName', javaName);
	binding.put('packageName', beanPackageName);
	
	new OutputStreamWriter(new FileOutputStream(fileName),MakeUtil.CHAR_SET).write(template.make(binding))
	
	println dir[dir.length - 1] + " Create !!!"
	
	pkListAll.addAll(pkList)
	colListAll.addAll(colList)
	javaColTypeMapAll.putAll(javaColTypeMap)
	colTypeMapAll.putAll(typeMap)
	
	tableRs.close();
	pkRs.close();
}

//###############################################################################
// 테이블의 모든 컬럼 타입을 체크하기 위함.
//###############################################################################
if(tableNames.size() > 0) {}
//###############################################################################
//Dao create
//###############################################################################
def files = []
beanFiles = new File(beanPath)
beanFiles.eachFileMatch(~/.*\.java/) { files << it.name.replaceAll('.java', '') }
fileName = daoPath + 'BeanDaoConfigDuzon.java'
FileOperator.createDirIfNotExist(fileName);
// DB와 매핑되는 class
def dbKindMapping = new HashMap<String, String>()
dbKindMapping.put(DBTableDao.DB_DB2, 'Db2Table')
dbKindMapping.put(DBTableDao.DB_MSSQL, 'MsSQLTable')
dbKindMapping.put(DBTableDao.DB_MYSQL, 'MySQLTable')
dbKindMapping.put(DBTableDao.DB_ORACLE, 'OracleTable')
dbKindMapping.put(DBTableDao.DB_SQLITE, 'SqliteTable')

def vendorClassName = 'mobile.factory.db.vendor.' + dbKindMapping[conf.dbKind]

def binding = [
	bean : files,
	daoPackageName : daoPackageName,
	beanPackageName : beanPackageName,
	vendorClassName : vendorClassName,
	currentDate : currentDate,
	currentTime : currentTime
]

new OutputStreamWriter(new FileOutputStream(fileName),MakeUtil.CHAR_SET).write(daoTemplate.make(binding))

dir = fileName.split("/")
println dir[dir.length - 1] + "\t\t Create !!!"

//###############################################################################
//DaoConfigService create
//###############################################################################
//###############################################################################
// db_column create // js관련 완료되면 확정
//###############################################################################
 // db_column create
if(conf.dbColumnJsName != '') {}

/**
 * 오라클일 경우에 쿼리로 테이블 Comment를 구함
 * @param sql
 */
def makeOracleCommentMap(def sql, def conf) {
	def map = new HashMap<String, String>()
	return map
}
