<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > null > 자료 목록
-- 작성자 : 박예진
-- 최초 작성일 : 2021-03-29 11:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
		
	    $(document).ready(function () {
	    });

    </script> 
</head>

<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<jsp:include page="/WEB-INF/jsp/common/lineworksHeader.jsp"></jsp:include>
<!-- 리스트 -->
            <div class="folder-items2 folder-step">
            	<div class="folder-lower">
            	<c:forEach var="item" items="${list}">
            		<a class="folder-item2">
	                    <c:if test="${item.file_type eq 'folder'}">
				 			<c:set var="lineDriveSeq" value="${item.line_drive_seq}"/>
				 			<c:set var="resourceKey" value="${item.resource_key}"/>
				 			<c:set var="fileType" value="y-folder"/>
	                    	<div class="thumb" onclick="javascript:goDepthPage('${item.line_drive_seq}', '${item.folder_level}');">
	                    </c:if>
	                    <c:if test="${item.file_type ne 'folder'}">
				 			<c:set var="lineDriveSeq" value="${item.up_line_drive_seq}"/>
				 			<c:set var="resourceKey" value="${item.up_resource_key}"/>
				 			<c:set var="fileType" value="${item.file_type}"/>
	                    	<div class="thumb" onclick="javascript:goLineworks('${item.up_resource_key}');">
	                    </c:if>
	                        <div class="hover"></div>
	                        <div class="btns">
		                    	<c:if test="${item.file_type ne 'folder'}">
		                            <button type="button" class="btn btn-icon btn-light" onclick="javascript:goDepthPage('${item.up_line_drive_seq}', '${item.file_level}');"><i class="material-iconsfolder text-default"></i></button>
		                    	</c:if>
		                        <button type="button" class="btn btn-icon btn-light" onclick="javascript:goLineworks('${resourceKey}');"><i class="material-iconslink text-default"></i></button>
	                        </div>
		                    <c:if test="${item.file_type eq 'folder'}"><div class="num">${item.child_folder_count}</div></c:if>
	                        <span class="icon-folder ${fileType}"></span>
	                    </div>
	                    <div class="info folder_name" id="${item.line_drive_seq}">
	                   		${item.line_name}
	                    </div>
	                </a>
				</c:forEach>
            </div>
            </div>
<!-- /리스트 -->
<!-- /시리즈1 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>