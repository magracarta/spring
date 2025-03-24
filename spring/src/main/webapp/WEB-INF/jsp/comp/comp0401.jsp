<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 직원연관팝업 > 직원연관팝업 > null > 직원조회
-- 작성자 : 손광진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<c:set var="set_agency_exclude_yn" value="${inputParam.s_agency_exclude_yn == '' || empty inputParam.s_agency_exclude_yn ? 'Y' : inputParam.s_agency_exclude_yn}"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function() {
			// readonly
			fnSetReadOnly('${inputParam.memReadOnlyField}'.split(','));
			// 그리드 생성
			createAUIGrid();

			// 받아온 대리점 제외값 체크 (신정애 사원은 대리점 제외 체크 해제->요청사항)
			// 신정애 사원님 대행으로 이금님 사원님으로 인한 추가 210525 김상덕
			if('${set_agency_exclude_yn}' == 'Y' && '${page.fnc.F00193_001}' != 'Y' ) {
				$("input:checkbox[id='s_agency_exclude_yn']").prop("checked", true);
			};

			if('${inputParam.s_repair_yn}' == 'Y') {
				$("#s_org_code").prop("disabled", true);
			}

			if ('${inputParam.s_mem_name}' != '') {
				goSearch();
			};
		});

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "mem_no",
				showRowNumColumn: true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "직원명",
				    dataField: "mem_name",
					width : "7%",
					style : "aui-center"
				},
				{
					headerText : "소속",
					dataField : "org_path_name",
					width: "30%",
					style : "aui-left"
				},
				{
				    headerText: "직책",
				    dataField: "grade_name",
					width : "8%",
					style : "aui-center"
				},
				{
				    headerText: "직급코드",
				    dataField: "grade_code",
					width : "8%",
					style : "aui-center",
					visible : false

				},
				{
				    headerText: "직급",
				    dataField: "job_name",
					width : "8%",
					style : "aui-center"
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width: "15%",
					style : "aui-center"
				},
				{
				    headerText: "휴대폰(og)",
				    dataField: "hp_no_real",
					width : "8%",
					style : "aui-center",
					visible : false

				},
				{
					headerText: "이메일",
					dataField: "email",
					width : "20%",
					style : "aui-center"
				},
				{
					headerText: "아이디",
					dataField: "web_id",
					width : "12%",
					style : "aui-center"
// 					, visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 클릭한 셀 데이터 받음
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				try {
					opener.${inputParam.parent_js_name}(event.item);
					window.close();
				} catch(e) {
					alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
				}

			});
		}

		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_mem_name", "s_hp_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		// 직원 조회
		function goSearch() {

			var param = {
				"s_mem_name" : $M.getValue("s_mem_name"),
				"s_hp_no" : $M.getValue("s_hp_no"),
				"s_org_code" : $M.getValue("s_org_code"),
				"s_work_status_cd" : $M.getValue("s_work_status_cd"),
				"s_agency_exclude_yn" : $M.getValue("s_agency_exclude_yn"),
			};

			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}

		//팝업 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<!-- <h2>직원조회</h2> -->
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="130px">
						<col width="60px">
						<col width="145px">
						<col width="60px">
						<col width="130px">
						<col width="70px">
						<col width="130px">
					</colgroup>
					<tbody>
						<tr>
							<th>부서</th>
							<td>
								<select id="s_org_code" name="s_org_code" class="form-control">
									<option value="">- 전체 -</option>
										<c:forEach items="${orgList}" var="item">
											<option value="${item.org_code}" ${item.org_code == inputParam.s_org_code ? 'selected="selected"' : ''}>${item.org_name}</option>
										</c:forEach>
								</select>
							</td>
							<th>직원명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_mem_name" name="s_mem_name" class="form-control" value="${inputParam.s_mem_name}" placeholder="아이디/직원번호/직원명">
								</div>
							</td>
							<th>휴대폰</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" placeholder="-없이 숫자만" size="5" datatype="int">
								</div>
							</td>
							<th>재직구분</th>
							<td>
								<select id="s_work_status_cd" name="s_work_status_cd" class="form-control" >
									<option value="">- 전체 -</option>
									<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
										<c:if test="${!empty inputParam.s_work_status_cd}">
											<option value="${list.code_value}" ${list.code_value == inputParam.s_work_status_cd ? 'selected="selected"' : ''} >${list.code_name}</option>
										</c:if>
										<c:if test="${empty inputParam.s_work_status_cd}">
											<option value="${list.code_value}" ${list.code_value == '01' ? 'selected="selected"' : ''} >${list.code_name}</option>
										</c:if>
									</c:forEach>
								</select>
							</td>
							<td>
								<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
								<%--<input type="checkbox" id="s_agency_exclude_yn" name="s_agency_exclude_yn" value="Y"/><label for="s_agency_exclude_yn">대리점제외</label>--%>
								<input type="checkbox" id="s_agency_exclude_yn" name="s_agency_exclude_yn" value="Y"/><label for="s_agency_exclude_yn">위탁판매점제외</label>
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<div id="auiGrid" style="margin-top: 5px; height: 400px"></div>
			<!-- 버튼영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- 버튼영역 -->
        </div>
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>
