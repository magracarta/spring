<%@ page pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><c:set var="uri" value="${fn:replace(pageContext.request.requestURI, '/WEB-INF/jsp/', '')}"/><c:set var="prefix" value="${fn:split(uri, '/')}"/><c:set var="tmp" value=""/><c:forEach var="str" items="${prefix}"><c:set var="tmp" value="${str}"/></c:forEach><c:set var="thisDir" value="/${fn:replace(uri, tmp, '')}"/><c:set var="thisPage" value="/${fn:replace(uri, '.jsp', '')}"/><c:set var="dataSet" value="${DATA_SET}"/><c:set var="pageNavi" value="${dataSet.pageNavi}"/><c:set var="listIdx" value="0"/><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>셀트리온스킨큐어 SCC</title>
	<link rel="stylesheet" type="text/css" href="/static/easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="/static/easyui/themes/icon.css">
    <link rel="stylesheet" type="text/css" href="/static/css/common.css" />
    <link rel="stylesheet" type="text/css" href="/static/css/jquery-ui.min.css" />
    <link rel="stylesheet" type="text/css" href="/static/css/jquery-ui.structure.min.css" />
    <link rel="stylesheet" type="text/css" href="/static/css/jquery-ui.theme.min.css" />
    
    <script type="text/javascript" src="/static/easyui/jquery.min.js"></script>
    <script type="text/javascript" src="/static/easyui/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="/static/easyui/jquery.edatagrid.js"></script>
    <script type="text/javascript" src="/static/easyui/locale/easyui-lang-ko.js"></script>
    <script type="text/javascript" src="/static/easyui/datagrid-scrollview.js"></script>
    <script type="text/javascript" src="/static/easyui/datagrid-bufferview.js"></script>
    <script type="text/javascript" src="/static/easyui/datagrid-cellediting.js"></script>    
    <script type="text/javascript" src="/static/js/jquery-ui.min.js"></script>    
	<script type="text/javascript" src="/static/js/db.column.js"></script>
	<script type="text/javascript" src="/static/js/jquery.mfactory-2.1.js"></script>	
	<script type="text/javascript" src="/static/js/open.panel.js"></script>
	<script type="text/javascript" src="/static/js/common.util.js"></script>
	<script type="text/javascript" src="/static/js/jquery.easyui.extend.js"></script>
	<script type="text/javascript" src="/static/js/jquery.form.min.js"></script>
	
	<script type="text/javascript">		
	//<c:set var="ctrl_host" value="${fn:toLowerCase(pageContext.request.requestURL)}"/><c:set var="ssl_host" value="scc.celltrionskincure.com"/><c:if test="${fn:startsWith(ctrl_host, 'http:') && fn:containsIgnoreCase(ctrl_host, ssl_host)}">location.href='https://${ssl_host }/main';</c:if>
		var this_page = '${thisPage}';	var this_dir = '${thisDir}'; window.focus();
		function goMain() {
			top.$M.goNextPage('/main');
		}
	</script>