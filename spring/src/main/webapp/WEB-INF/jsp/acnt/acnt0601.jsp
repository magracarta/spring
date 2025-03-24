<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-13 11:20:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_kor_name", "s_org_code"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "사용자관리");
		}

		// 행 추가
		function goAdd() {
			$M.goNextPage("/comm/comm060101");
		}

		// 직원목록 조회
		function goSearch() {
			var param = {
				"s_kor_name": $M.getValue("s_kor_name"),
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_type_cd": $M.getValue("s_mem_type_cd"),
				"s_work_status_cd": $M.getValue("s_work_status_cd"),
				"s_mem_org_cd": $M.getValue("s_mem_org_cd"),
				"s_mem_job_auth_cd": $M.getValue("s_mem_job_auth_cd"),
				"s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"s_sort_key": "path_org_code asc, grade_cd",
				"s_sort_method": "desc"
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "get"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}

		// 직원신규등록
		function goNew() {
			$M.goNextPage('/acnt/acnt060101');
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "mem_no",
				showRowNumColumn: true,
				fillColumnSizeMode: false,
				editable: false,
				headerHeight: 40
			};

			var columnLayout = [
				{
					headerText: "부서",
					dataField: "path_org_name",
					width: "240",
					minWidth: "230",
					style: "aui-left"
				},
				{
					headerText: "직원명",
					dataField: "kor_name",
					width: "100",
					minWidth: "90",
					style: "aui-center aui-popup"
				},
				{
					headerText: "직급",
					dataField: "job_name",
					width: "60",
					minWidth: "50",
					style: "aui-center"
				},
				{
					headerText: "직책",
					dataField: "grade_name",
					width: "60",
					minWidth: "50",
					style: "aui-center"
				},
				{
					headerText: "아이디",
					dataField: "web_id",
					width: "100",
					minWidth: "90",
					style: "aui-center"
				},
				{
					headerText: "사번",
					dataField: "emp_id",
					width: "100",
					minWidth: "90",
					style: "aui-center"
				},
				{
					headerText: "휴대전화",
					dataField: "hp_no",
					width: "100",
					minWidth: "45",
					style: "aui-center",
				},
				{
					headerText: "이메일",
					dataField: "email",
					width: "160",
					minWidth: "150",
					style: "aui-left"
				},
				{
					headerText: "생년월일",
					dataField: "birth_dt",
					dataType: "date",
					width: "65",
					minWidth: "55",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "입사년월일",
					dataField: "ipsa_dt",
					dataType: "date",
					width: "65",
					minWidth: "55",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "퇴직년월일",
					dataField: "retire_dt",
					dataType: "date",
					width: "65",
					minWidth: "55",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "부서권한",
					dataField: "mem_org_name",
					width: "200",
					minWidth: "190",
					style: "aui-left",
				},
				{
					headerText: "업무권한",
					dataField: "mem_job_auth_name",
					width: "140",
					minWidth: "130",
					style: "aui-left",
				},
				{
					headerText: "사무실",
					dataField: "office_tel_no",
					width: "100",
					minWidth: "45",
					style: "aui-center",
				},
				{
					headerText: "재직<br>구분",
					dataField: "work_status_name",
					width: "40",
					minWidth: "40",
					style: "aui-center",
				},
				{
					headerText: "직원<br>구분",
					dataField: "mem_type_name",
					width: "60",
					minWidth: "50",
					style: "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "kor_name") {
					var param = {
						"s_mem_no": event.item.mem_no,
						"s_grade_cd": event.item.grade_cd,
						"s_org_code": event.item.path_org_code,
					};
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
					$M.goNextPage("/acnt/acnt0601p01", $M.toGetParam(param), {popupStatus: popupOption, method:"post"});
				}
			});
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="55px">
								<col width="100px">
								<col width="40px">
								<col width="150px">
								<col width="65px">
								<col width="90px">
								<col width="65px">
								<col width="90px">
								<col width="65px">
								<col width="200px">
								<col width="65px">
								<col width="90px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>직원명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_kor_name" name="s_kor_name" maxlength="10" alt="직원명">
									</div>
								</td>
								<th>부서</th>
								<td>
									<input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid" easyuiname="pathOrgList" panelwidth="350" idfield="org_code" textfield="path_org_name" multi="N"/>
								</td>
								<th>직원구분</th>
								<td>
									<select class="form-control" id="s_mem_type_cd" name="s_mem_type_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['MEM_TYPE']}">
											<option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>재직구분</th>
								<td>
									<select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
											<option value="${list.code_value}" <c:if test="${list.code_value eq '01'}">selected</c:if>>${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>부서권한</th>
								<td>
									<select class="form-control" id="s_mem_org_cd" name="s_mem_org_cd" alt="부서권한">
										<option value="">- 선택 -</option>
										<c:forEach items="${menuOrgList}" var="item">
											<option value="${item.org_code}">${item.path_org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>업무권한</th>
								<td>
									<input class="form-control" style="width: 99%;" type="text" id="s_mem_job_auth_cd" name="s_mem_job_auth_cd" easyui="combogrid" easyuiname="jobAuthList" panelwidth="300" idfield="code_value" textfield="code_name" multi="N"/>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>직원목록</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">${s_masking_default_yn}
										<input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
									</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 550px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>