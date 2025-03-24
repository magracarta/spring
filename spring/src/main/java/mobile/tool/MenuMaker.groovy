package mobile.tool

import groovy.sql.Sql
import groovy.text.SimpleTemplateEngine

def rootDir = MakeUtil.ROOT_DIR
def engine = new SimpleTemplateEngine()

// 환경설정 파일 로딩
def conf = MakeUtil.getConf();

def template = engine.createTemplate(new InputStreamReader(new FileInputStream(rootDir + '/src/main/java/mobile/tool/MenuDefine.template'), MakeUtil.CHAR_SET))

// 코드 조회 추출
def sql = Sql.newInstance(conf.url, conf.id, conf.passwd, conf.driverClassName)

def list = sql.rows(conf.menuQuery)
def binding = [
	menuPackageName : conf.menuPackageName,
	list : list,
	currentDate : mobile.factory.util.DateUtil.getCurrentDate("yyyy-MM-dd"),
	currentTime : mobile.factory.util.DateUtil.getCurrentDate("HH:mm:ss"),
]
// 파일명 확인
def fileName = rootDir + conf.menuPath + 'MenuDefine.java'
FileOperator.createDirIfNotExist(fileName);

def codeFileText = template.make(binding)

new OutputStreamWriter(new FileOutputStream(fileName),MakeUtil.CHAR_SET).write(codeFileText)
println fileName + ' Create !!!'