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
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		#dir_folder {
			/* 창 세로 -  타이틀바 + 검색창 */
			height: calc(100vh - 170px);
			position: inherit;
		}
		iframe {
			height: 100%;
			width: 100%;
			min-height: 100px;
			border: 0;
		}
	</style>
    <script type="text/javascript">
		var listIndex = 1;

		$(document).ready(function () {
			if (${not empty inputParam.s_machine_seq} || ${not empty inputParam.s_machine_plant_seq}) {
				if (${not empty inputParam.s_machine_plant_seq}) {
					$M.setValue("s_machine_plant_seq", ${inputParam.s_machine_plant_seq});
				} else {
					$M.setValue("s_machine_seq", ${inputParam.s_machine_seq});
				}
				goSearch();
			}
		});

		// 파일 등록
		function fnUpload(params){
			if (params.work_db_file_seq)
				$M.goNextPage('/workDb2/workDb0106', $M.toGetParam(params), {popupStatus : getPopupProp(1200, 850)})
			else
				$M.goNextPage('/workDb2/workDb0103', $M.toGetParam(params), {popupStatus : getPopupProp(1200, 850)})
		}

		function goMain(work_db_seq){
			var params = { work_db_seq : work_db_seq };
			$("#dir").attr("src","/workDb2/workDb0102?" + $M.toGetParam(params));
		}

		// 페이지 크기 조정 - jquery 로 안먹음
		function fnReload(){
			document.getElementById('dir').contentDocument.location.reload();
		}

		// 검색
		function goSearch(){
			var params = { };
			var target = $("#main_form");

			// 입력된 값 삽입
			for (var str of ["s_title", "s_tag", "s_description", "s_maker_cd", "s_machine_plant_seq", "s_st_body_no", "s_ed_body_no", "s_file_name", "s_machine_seq"]){
				var val = target.find("#" + str).val();
				if (val.length > 0) {
					params[str] = val;
				}
			}

			// 만료여부 값 삽입
			if (document.getElementById('s_expire_yn').checked) {
				params["s_expire_yn"] = "Y";
			}

			$("#dir").attr("src","/workDb2/workDb0102?" + $M.toGetParam(params));
		}

        // 닫기
        function fnClose() {
            window.close();
        }

		// 엔터키 이벤트
		function enter(fieldObj) {
			// 제목, 내용검색
			const field = ["s_title", "s_description", "s_st_body_no", "s_ed_body_no", "s_file_name"];
			field.forEach(name => {
				if (fieldObj.name == name) {
					goSearch();
				}
			});
		}

		// FROM 차대번호 세팅
		function fnSetStMch(data) {
			$M.setValue("s_st_body_no", data.body_no);
		}

		// TO 차대번호 세팅
		function fnSetEdMch(data) {
			$M.setValue("s_ed_body_no", data.body_no);
		}
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="s_machine_seq" id="s_machine_seq">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<div class="left" style="width:100%;">
					<h4 class="mr10" style="font-size:13px; font-weight:bold;">업무DB</h4>
				</div>
			</div>
			<%--	검색조건	--%>
			<div class="search-wrap mt5">
				<table class="table table-fixed">
					<colgroup>
						<!-- 제목 -->
						<col width="35px">
						<col width="110px">
						<!-- 파일명 -->
						<col width="40px">
						<col width="110px">
						<!-- 태그 -->
						<col width="35px">
						<col width="110px">
						<!-- 메이커 -->
						<col width="50px">
						<col width="80px">
						<!-- 모델명 -->
						<col width="50px">
						<col width="140px">
						<!-- 차대번호 -->
						<col width="55px">
						<col width="210px">
						<!-- 내용검색 -->
						<col width="55px">
						<col width="*">
						<col width="85px">
						<col width="50px">
					</colgroup>
					<tbody>
					<tr>
						<th>제목</th>
						<td>
							<input type="text" class="form-control" id="s_title" name="s_title">
						</td>
						<th>파일명</th>
						<td>
							<input type="text" class="form-control" id="s_file_name" name="s_file_name">
						</td>
						<th>태그</th>
						<td>
							<input class="form-control" style="width: 99%;" type="text" id="s_tag" name="s_tag_cd" easyui="combogrid"
								   easyuiname="tagList" panelwidth="200" idfield="code_value" textfield="code_name" multi="Y"/>
						</td>
						<th>메이커</th>
						<td>
							<select id="s_maker_cd" name="s_maker_cd" class="form-control">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['MAKER']}" var="item">
									<c:if test="${item.code_v1 eq 'Y'}">
										<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th>모델명</th>
						<td>
							<input type="text" style="width : 130px"
								   id="s_machine_plant_seq"
								   name="s_machine_plant_seq"
								   easyui="combogrid"
								   header="N"
								   easyuiname="machineName"
								   panelwidth="150"
								   maxheight="300"
								   textfield="machine_name"
								   multi="N"
								   enter="goSearch()"
								   idfield="machine_plant_seq" />
						</td>
						<th>차대번호</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" id="s_st_body_no" name="s_st_body_no" class="form-control" placeholder="시작">
<%--									<div class="input-group width140px">--%>
<%--										<input type="text" id="s_st_body_no" name="s_st_body_no" class="form-control border-right-0" placeholder="시작">--%>
<%--										<button type="button" class="btn btn-icon btn-primary-gra" onclick="openSearchDeviceHisPanel('fnSetStMch', $M.toGetParam({}))"><i class="material-iconssearch"></i></button>--%>
<%--									</div>--%>
								</div>
								<div class="col width16px">~</div>
								<div class="col width100px">
									<input type="text" id="s_ed_body_no" name="s_ed_body_no" class="form-control" placeholder="끝">
<%--									<div class="input-group width140px">--%>
<%--										<input type="text" id="s_ed_body_no" name="s_ed_body_no" class="form-control border-right-0" placeholder="끝">--%>
<%--										<button type="button" class="btn btn-icon btn-primary-gra" onclick="openSearchDeviceHisPanel('fnSetEdMch', $M.toGetParam({}))"><i class="material-iconssearch"></i></button>--%>
<%--									</div>--%>
								</div>
							</div>
						</td>
						<th>내용검색</th>
						<td>
							<input type="text" class="form-control" id="s_description" name="s_description">
						</td>
						<td>
							<input type="checkbox" id="s_expire_yn" name="s_expire_yn">만료된자료</td>
						<td>
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<%--	검색조건	--%>
			<%-- css 연산테그 (100vh : 현창의 가로 100%) -  (12vh : 현창의 가로 12%) / calc - 연산 --%>
			<div id="dir_folder">
				<iframe id="dir" src="/workDb2/workDb0102?work_db_seq=${not empty inputParam.work_db_seq ? inputParam.work_db_seq : '0'}"></iframe>
			</div>
		</div>
	</div>
</form>
</body>
</html>
