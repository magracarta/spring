<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB2 > 업무DB팝업 > null > 업무DB팝업
-- 작성자 : 류성진
-- 최초 작성일 : 2023-02-24
/workDb2/workDb0102?
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
		var listIndex = 1;
		var disListIndex = 1;

        $(document).ready(function () {
			<c:if test="${empty inputParam.work_db_seq or inputParam.work_db_seq eq '0'}">
				$("#_fnCancel").hide();
			</c:if>
        });

	</script>
	<style>
		html, #main_form{
			height: inherit;
		}
	</style>
</head>

<body class="bg-white">
<form id="main_form" name="main_form" style="padding-right: 10px;">
	<!-- 파일 리스트 -->

	<hr class="div-line" />
	<jsp:include page="/WEB-INF/jsp/common/workDbFiles.jsp"/>
	<!-- /메이커 분류 (판매중) -->

	<!-- 최신업로드파일 -->
	<%-- 페이지 재사용 - 최근 업로드 데이터가 있는 경우에만 출력 --%>
	<c:if test="${not empty recentFile}" >
	<div class="title-wrap mt10">
		<div class="left"><h4>최신 업로드 파일</h4></div>
	</div>
	<hr class="div-line" />
	<div class="folder-items2">
		<c:forEach var="item" items="${recentFile}">
			<a id="file_item_${item.seq}" href="javascript:goFile({seq : '${item.seq}', file_seq : '${item.file_seq}', view_url : '${item.view_url}'})" class="folder-item2">
				<div class="thumb">
					<div class="hover"></div>
					<div class="btns">
						<!-- 다운로드 -->
						<c:if test="${item.is_download ne '0' or SecureUser.mem_no eq item.reg_id}">
						<button type="button" class="btn btn-icon btn-light" onclick="dowloadFile(event, {file_seq : '${item.file_seq}', seq : '${item.seq}'})" title="파일 다운로드"><i class="material-iconscloud_download text-default"></i></button>
						</c:if>
						<c:if test="${SecureUser.mem_no eq item.reg_id or page.fnc.F04409_001 eq 'Y'}">
						<button type="button" class="btn btn-icon btn-light" onclick="fnEditFile(event, ${item.seq})" title="파일 편집"><i class="material-iconsedit text-default"></i></button>
						<%-- 제거 --%>
						<button type="button" class="btn btn-icon btn-light" onclick="fnDelFile(event, ${item.seq}, ${item.up_work_db_seq})" title="파일 삭제"><i class="material-iconsclose text-default"></i></button>
						</c:if>
					</div>
					<%-- file_ext --%>
					<c:choose>
						<c:when test="${item.file_ext eq 'jpg' or item.file_ext eq 'png' or item.file_ext eq 'jpeg' or item.file_ext eq 'gif' or item.file_ext eq 'tif'}">
							<!-- 이미지 -->
							<span class="icon-folder img"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'avi' or item.file_ext eq 'mpg' or item.file_ext eq 'wmv'}">
							<!-- 비디오 -->
							<span class="icon-folder video"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'zip'}">
							<!-- 압축파일 -->
							<span class="icon-folder zip"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'exe'}">
							<!-- 실행파일 -->
							<span class="icon-folder exe"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'txt'}">
							<!-- 실행파일 -->
							<span class="icon-folder txt"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'doc' or item.file_ext eq 'docx' or item.file_ext eq 'msi' or item.file_ext eq 'pot' or item.file_ext eq 'hwp'}">
							<!-- 문서 -->
							<span class="icon-folder doc"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'pdf'}">
							<!-- PDF 파일 -->
							<span class="icon-folder pdf"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'ppt' or item.file_ext eq 'pptx'}">
							<!-- PPT 파일 -->
							<span class="icon-folder ppt"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'xlsx' or item.file_ext eq 'xls'}">
							<!-- 엑셀 파일 -->
							<span class="icon-folder xlsx"></span>
						</c:when>
					</c:choose>
					<%-- file_ext --%>
				</div>
				<div class="date">
					<fmt:formatDate value="${item.reg_date}" pattern="yyyy-MM-dd" var="date" />
					${date}
				</div>
				<div class="info" data-origin="${item.name}">${item.name}</div>
				<div class="date">${item.tags}</div>
			</a>
		</c:forEach>
	</div>
	</c:if>
	<!-- /최신 업로드 파일 -->
	<!-- 최근 열어본 파일 -->
	<c:if test="${not empty recentReadFile}" >
	<div class="title-wrap mt10">
		<div class="left"><h4>최근 열어본 파일</h4></div>
	</div>
	<hr class="div-line" />
	<div class="folder-items2">
		<c:forEach var="item" items="${recentReadFile}">
			<a id="file_item_${item.seq}" href="javascript:goFile({seq : '${item.seq}', file_seq : '${item.file_seq}', view_url : '${item.view_url}'})" class="folder-item2">
				<div class="thumb">
					<div class="hover"></div>
					<div class="btns">
						<!-- 다운로드 -->
						<c:if test="${item.is_download ne '0' or SecureUser.mem_no eq item.reg_id}">
						<button type="button" class="btn btn-icon btn-light" onclick="dowloadFile(event, {file_seq : '${item.file_seq}', seq : '${item.seq}'})" title="파일 다운로드"><i class="material-iconscloud_download text-default"></i></button>
						</c:if>
						<c:if test="${SecureUser.mem_no eq item.reg_id or page.fnc.F04409_001 eq 'Y'}">
						<button type="button" class="btn btn-icon btn-light" onclick="fnEditFile(event, ${item.seq})" title="파일 편집"><i class="material-iconsedit text-default"></i></button>
						<%-- 제거 --%>
						<button type="button" class="btn btn-icon btn-light" onclick="fnDelFile(event, ${item.seq}, ${item.up_work_db_seq})" title="파일 삭제"><i class="material-iconsclose text-default"></i></button>
						</c:if>
					</div>
					<%-- file_ext --%>
					<c:choose>
						<c:when test="${item.file_ext eq 'jpg' or item.file_ext eq 'png' or item.file_ext eq 'jpeg' or item.file_ext eq 'gif' or item.file_ext eq 'tif'}">
							<!-- 이미지 -->
							<span class="icon-folder img"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'avi' or item.file_ext eq 'mpg' or item.file_ext eq 'wmv'}">
							<!-- 비디오 -->
							<span class="icon-folder video"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'zip'}">
							<!-- 압축파일 -->
							<span class="icon-folder zip"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'exe'}">
							<!-- 실행파일 -->
							<span class="icon-folder exe"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'txt'}">
							<!-- 실행파일 -->
							<span class="icon-folder txt"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'doc' or item.file_ext eq 'docx' or item.file_ext eq 'msi' or item.file_ext eq 'pot' or item.file_ext eq 'hwp'}">
							<!-- 문서 -->
							<span class="icon-folder doc"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'pdf'}">
							<!-- PDF 파일 -->
							<span class="icon-folder pdf"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'ppt' or item.file_ext eq 'pptx'}">
							<!-- PPT 파일 -->
							<span class="icon-folder ppt"></span>
						</c:when>
						<c:when test="${item.file_ext eq 'xlsx' or item.file_ext eq 'xls'}">
							<!-- 엑셀 파일 -->
							<span class="icon-folder xlsx"></span>
						</c:when>
					</c:choose>
					<%-- file_ext --%>
				</div>
				<div class="date">
					<fmt:formatDate value="${item.reg_date}" pattern="yyyy-MM-dd" var="date" />
					${date}
				</div>
				<div class="info" data-origin="${item.name}">${item.name}</div>
				<div class="date">${item.tags}</div>
			</a>
		</c:forEach>
	</div>
	</c:if>
	<!-- /최근 열어본 파일 -->
	<%--	버튼 그룹	--%>
	<div class="btn-group mt10 mb10">
		<div class="right">
			<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
		</div>
	</div>
</form>
</body>
</html>