<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 사용자관리 > null > null
-- 작성자 : 강명지
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var page = 1;
		var rows = 50;
		var moreFlag = "N";

		$(document).ready(function() {
			createAUIGrid();
		});

		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "사용자관리", exportProps);
		}

		function goAdd() {
			$M.goNextPage("/comm/comm010801");
		}

		function enter(fieldObj) {
			var field = ["s_kor_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		function goSearch() {
			moreFlag = "N";
			var param = {
					"page" : page,
					"rows" : rows,
					"s_kor_name" : $M.getValue("s_kor_name"),
					"s_org_code" : $M.getValue("s_org_code"),
					"s_work_status_cd" : $M.getValue("s_work_status_cd"),
					"s_agency_exclude_yn" : $M.getValue("s_agency_exclude_yn"),
					"s_mem_org_cd" : $M.getValue("s_mem_org_cd"),
					"s_mem_job_auth_cd" : $M.getValue("s_mem_job_auth_cd"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
						if (result.more_yn == 'Y') {
							moreFlag = "Y";
							page++;
						};
					};
				}
			);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
				height : 555
			};
			var columnLayout = [
				{
					dataField : "mem_no",
					visible : false
				},
				{
					headerText : "아이디",
					dataField : "web_id",
					width : "7%",
					style : "aui-center  aui-editable"
				},
				{
					headerText : "직원명",
					dataField : "kor_name",
					width : "6%",
					style : "aui-center"
				},
				{
					headerText : "부서",
					dataField : "path_org_name",
					width : "17%",
					style : "aui-left"
				},
				{
					headerText : "직급",
					dataField : "grade_name",
					width : "6%",
					style : "aui-center"
				},
				{
					headerText : "직책",
					dataField : "job_name",
					width : "6%",
					style : "aui-center"
				},
				{
					headerText : "입사년월일",
					dataField : "ipsa_dt",
					dataType : "date",
					width : "7%",
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "퇴직년월일",
					dataField : "retire_dt",
					dataType : "date",
					width : "7%",
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "생년월일",
					dataField : "birth_dt",
					dataType : "date",
					width : "7%",
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "부서권한",
					dataField : "mem_org_name",
					width : "14%",
					style : "aui-left",
				},
				{
					headerText : "업무권한",
					dataField : "mem_job_auth_name",
					width : "14%",
					style : "aui-left",
				},
				{
					headerText : "휴대전화",
					dataField : "hp_no",
					width : "10%",
					style : "aui-center",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						return fnGetHPNum(value);
// 					}
				},
				{
					headerText : "사무실",
					dataField : "office_tel_no",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "이메일",
					dataField : "email",
					width : "13%",
					style : "aui-center",
				},
				{
					headerText : "재직구분",
					dataField : "work_status_name",
					style : "aui-center",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "web_id") {
					var param = {
							"s_mem_no" : event.item.mem_no
					};
					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1350, height=470, left=0, top=0";
					$M.goNextPage('/comm/comm0108p01', $M.toGetParam(param), {popupStatus : poppupOption});
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
	<!-- 기본 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
								<col width="50px">
								<col width="100px">
								<col width="40px">
								<col width="130px">
								<col width="60px">
								<col width="100px">
								<col width="80px">
								<col width="50px">
								<col width="110px">
								<col width="60px">
								<col width="120px">
								<col width="90px">
							</colgroup>
						<tbody>
							<tr>
								<th>직원명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_kor_name" name="s_kor_name">
										</div>
									</td>
								<th>부서</th>
								<td>
									<input class="form-control" style="width: 99%;"type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
										easyuiname="pathOrgList" panelwidth="350" idfield="org_code" textfield="path_org_name" multi="N"/>
								</td>
								<th>재직구분</th>
								<td>
									<select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
											<option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<input type="checkbox" id="s_agency_exclude_yn" name="s_agency_exclude_yn" checked="checked" value="Y"/><label for="s_agency_exclude_yn">대리점제외</label>--%>
									<input type="checkbox" id="s_agency_exclude_yn" name="s_agency_exclude_yn" checked="checked" value="Y"/><label for="s_agency_exclude_yn">위탁판매점제외</label>
								</td>
								<th>부서권한</th>
								<td>
									<input class="form-control" style="width: 99%;"type="text" id="s_mem_org_cd" name="s_mem_org_cd" easyui="combogrid"
										easyuiname="orgAuthList" panelwidth="300" idfield="org_code" textfield="org_name" multi="N"/>
								</td>
								<th>업무권한</th>
								<td>
									<input class="form-control" style="width: 99%;"type="text" id="s_mem_job_auth_cd" name="s_mem_job_auth_cd" easyui="combogrid"
										easyuiname="jobAuthList" panelwidth="300" idfield="code_value" textfield="code_name" multi="N"/>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
	<!-- /기본 -->
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
							<div class="form-check form-check-inline">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</div>
							</c:if>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div id="auiGrid" style="margin-top: 5px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
	</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
