<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드 > 모델별 정기검사주기 관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-03-25 13:50:44
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
		});

		function createAUIGrid() {
			var gridPros = {
				editable: true,
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: true,
				enableSorting: true,
				showStateColumn: true
			};
			var columnLayout = [
				{
					headerText: "메이커",
					dataField: "maker_name",
					width: "30%",
					style: "aui-center",
					editable: false,
					required: true
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width: "40%",
					style: "aui-center",
					editable: false,
					required: true
				},
				{
					headerText: "기 검사기간(년)",
					dataField: "check_cycle_year",
					dataType: "numeric",
					style: "aui-center aui-editable",
					editable: true,
					required: true,
					editRenderer: {
						type: "InputEditRenderer",
						onlyNumeric: true
					}
				},
				{
					headerText : "장비번호",
					dataField : "machine_plant_seq",
					visible : false
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			$("#auiGrid").resize();
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_machine_name", "s_maker_cd"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 조회
		function goSearch() {
			var param = {
				s_machine_name: $M.getValue("s_machine_name"),
				s_maker_cd: $M.getValue("s_maker_cd")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			;
			if (fnCheckGridEmpty(auiGrid) === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'POST'},
					function (result) {
						if (result.success) {
							goSearch();
						}
					}
			);
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validation(auiGrid);
		}

		//정기검사 유효기간 안내 팝업
		function goPopupCheckCycleInfo() {
			openCheckCycleInfoPanel('setCheckCycleInfoPanel');
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
				<div class="contents" style="width : 60%;">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="150px">
								<col width="50px">
								<col width="150px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${makerlist}">
											<option value="${item.maker_cd}">${item.maker_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>모델명</th>
								<td>
									<input type="text" class="form-control width120px" id="s_machine_name" name="s_machine_name">
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
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;">
				</div>
				<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>