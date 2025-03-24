package mobile.tool.file

import org.apache.commons.lang3.StringUtils

import groovy.sql.Sql
import groovy.text.SimpleTemplateEngine
import mobile.factory.util.DateUtil
import mobile.tool.FileOperator
import mobile.tool.MakeUtil

def rootDir = StringUtils.replace( MakeUtil.ROOT_DIR, '\\', '/')
def engine = new SimpleTemplateEngine()

// 환경설정 파일 로딩
def conf = MakeUtil.getConf();
def controllerTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/file/Controller.template"), 'utf-8'))
def testControllerTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/file/TestController.template"), 'utf-8'))
def serviceTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/file/Service.template"), 'utf-8'))
def serviceImplTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/file/ServiceImpl.template"), 'utf-8'))
def jspListTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/file/JspList.template"), 'utf-8'))
def jspAddTemplate = engine.createTemplate(new InputStreamReader(getClass().getResourceAsStream("/mobile/tool/file/JspAdd.template"), 'utf-8'))

// 코드 조회 추출
def sql = Sql.newInstance(conf.url, conf.id, conf.passwd, conf.driverClassName)
def query = ''' select * from t_java_mapping  where 1=1 '''
def colNameQuery = 
'''  
  select 
    column_name
  from dba_tab_columns 
  where table_name = 'T_JAVA_MAPPING'
  and column_name like 'BTN_%'
  and owner = 'CELL'
'''
def list = sql.rows(query)
def colNameList = sql.rows(colNameQuery)

String controllerRoot = rootDir + '/src/main/java/sunnyyk/erp/web/controller'
String testControllerRoot = rootDir + '/src/test/java/sunnyyk/erp/web/controller'
String serviceRoot = rootDir + '/src/main/java/sunnyyk/erp/common/service/web'
String jspRoot = rootDir + '/src/main/webapp/WEB-INF/jsp'
String javaPackagePrefix = '/src/main/java/'

list.each { 
	boolean existsFile = false
	// Controller
	boolean overwriteController = "Y".equals(it.get('OVERWRITE_CONTROLLER'))
	String controllerFilePath = String.format("%s%s.java", controllerRoot, it.get("CONTROLLER")) 
	existsFile = FileOperator.existsFile(controllerFilePath)
	
	boolean controllerCreate = (existsFile == false || overwriteController)
	
	// testController
	boolean overwriteTestController = "Y".equals(it.get('OVERWRITE_TEST_CONTROLLER'))
	String prefix = StringUtils.substringBeforeLast(it.get("CONTROLLER"), '/')
	String postfix =  StringUtils.substringAfterLast(it.get("CONTROLLER"), '/')
	String fileName = String.format('%s/Test%s', prefix, postfix)
	String testControllerFilePath = String.format("%s%s.java", testControllerRoot, fileName)
	
	existsFile = FileOperator.existsFile(testControllerFilePath)
	
	boolean testControllerCreate = (existsFile == false || overwriteTestController)
	
	// Service
	String serviceFilePath = String.format("%s%s.java", serviceRoot, it.get("SERVICE"))
	existsFile = FileOperator.existsFile(serviceFilePath)
	
	boolean serviceCreate = (existsFile == false || overwriteController)
//	
//	// JSP
	boolean overwritePage = "Y".equals(it.get('OVERWRITE_PAGE'))
	String jspFilePath = String.format("%s%s.jsp", jspRoot, it.get("PAGE_URL"))
	existsFile = FileOperator.existsFile(jspFilePath)
	
	boolean jspCreate = (existsFile == false || overwritePage)
	
	//########################################################################################################################################################################
	// 파일 생성시 필요한 변수 가공
	String menuDepthName = String.format("%s > %s > %s > %s > %s", it.get('LEVEL1'), it.get('LEVEL2'), it.get('LEVEL3'), it.get('LEVEL4'), it.get('LEVEL5'))
	String controllerPackagePath = StringUtils.replace( StringUtils.substringBeforeLast( StringUtils.substringAfter(controllerFilePath, javaPackagePrefix), '/'), '/', '.')
	String servicePackagePath = StringUtils.replace( StringUtils.substringBeforeLast( StringUtils.substringAfter(serviceFilePath, javaPackagePrefix), '/'), '/', '.')
	String controllerName =  StringUtils.substringBeforeLast( StringUtils.substringAfterLast(controllerFilePath, '/'), '.')
	String testControllerName = 'Test' + StringUtils.substringBeforeLast( StringUtils.substringAfterLast(controllerFilePath, '/'), '.')
	String controllerMemberName =  controllerName.substring(0, 4).toLowerCase() + controllerName.substring(4)
	String serviceName =  StringUtils.substringBeforeLast( StringUtils.substringAfterLast(serviceFilePath, '/'), '.')
	String serviceMemberName = serviceName.substring(0, 4).toLowerCase() + serviceName.substring(4)
	String rootUrl = StringUtils.substringBeforeLast(it.get('PAGE_URL'), '/')
	String subUrl = StringUtils.removeStart(it.get('PAGE_URL'), rootUrl)
	String date = DateUtil.getCurrentDate('yyyy-MM-dd')
	String time = DateUtil.getCurrentDate('HH:mm:ss')
	
//	// 생성할 메소드명 가공
	List<String> methodList = new ArrayList<String>()
	List<String> jsMethodList = new ArrayList<String>()
//	colNameList.each { row ->
//		// 자바스크립트 전용메소드인지 체크 
//		String columnName = row.get('COLUMN_NAME')
//		boolean onlyJS = StringUtils.endsWith(columnName, '_J')
//				
//		String methodName = it.get(columnName)
//		if(StringUtils.isNotBlank(methodName)) {
//			String jsMethodName = methodName
//			if(onlyJS == false) {
//				methodList.add(methodName)
//				jsMethodName = String.format('go%s', methodName.substring(0,1).toUpperCase() + methodName.substring(1))
//			}
//			
//			jsMethodList.add(jsMethodName)
//		}
//	}
	
	def binding = [
		controllerPackagePath : controllerPackagePath,
		servicePackagePath : servicePackagePath,
		serviceName : serviceName,
		serviceMemberName : serviceMemberName,
		menuDepthName : menuDepthName,
		controllerName : controllerName,
		testControllerName : testControllerName,
		controllerMemberName : controllerMemberName,
		rootUrl : rootUrl,
		subUrl : subUrl,
		date : date,
		time : time,
		level1 : it.get('LEVEL1'),
		level2 : it.get('LEVEL2'),
		level3 : it.get('LEVEL3'),
		level4 : it.get('LEVEL4'),
		level5 : it.get('LEVEL5'),
		methodList : methodList,
		jsMethodList : jsMethodList
	]
	
	//########################################################################################################################################################################
	
	// Service 생성
	if(serviceCreate ) {
		FileOperator.createDirIfNotExist(serviceFilePath);
		
		new OutputStreamWriter(new FileOutputStream(serviceFilePath),'utf-8').write(serviceTemplate.make(binding))
		
		String serviceImplFilePath = StringUtils.replace(serviceFilePath, '.java', 'Impl.java')
		new OutputStreamWriter(new FileOutputStream(serviceImplFilePath),'utf-8').write(serviceImplTemplate.make(binding))
		
		println StringUtils.substringAfterLast(serviceFilePath, '/') + '#' + StringUtils.substringAfterLast(serviceImplFilePath, '/') + " Create !!!"
	}
	
	// Controller 생성
	if(controllerCreate) {
		FileOperator.createDirIfNotExist(controllerFilePath);
		
		new OutputStreamWriter(new FileOutputStream(controllerFilePath),'utf-8').write(controllerTemplate.make(binding))
		println StringUtils.substringAfterLast(controllerFilePath, '/') + " Create !!!"
	}
	
	// testController 생성
	if(testControllerCreate && methodList.size() > 0) {
		FileOperator.createDirIfNotExist(testControllerFilePath);
		
		new OutputStreamWriter(new FileOutputStream(testControllerFilePath),'utf-8').write(testControllerTemplate.make(binding))
		println StringUtils.substringAfterLast(testControllerFilePath, '/') + " Create !!!"
	}
	
	// JSP 생성
	if(jspCreate) {
		FileOperator.createDirIfNotExist(jspFilePath);
		
		// JSP 파일에는 특성상 <% 가 들어가는데, 템플릿 생성시 그루비 코드로 인식하니.. 임시로 <% -> &lt;% 로 변경후, 변환된 문자를 다시 원복
		String fileText = ""
		String pageId = it.get("ID")
		if(pageId.length() == 8) {	// 리스트
			fileText = jspListTemplate.make(binding)
		} else if (pageId.length() > 8 && pageId.contains("P") == false) { // 상세
			fileText = jspAddTemplate.make(binding)
		} else {	// 팝업
			fileText = jspListTemplate.make(binding)
		}
		
		fileText = StringUtils.replace(fileText, '&lt;%', '<%')
		
		Writer writer = new OutputStreamWriter(new FileOutputStream(jspFilePath),'utf-8')
		writer.write(fileText)
		writer.flush()
//		new OutputStreamWriter(new FileOutputStream(jspFilePath),'utf-8').write(jspTemplate.make(binding))
		
		println StringUtils.substringAfterLast(jspFilePath, '/') + " Create !!!"
	}
}
