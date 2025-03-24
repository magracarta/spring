<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비코드관리 > 장비코드관리 > null > 판매가 변동내역(구 단가관리)
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-25 10:52:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var list = ${list};  // 출하단가목록 조회 쿼리

	var auiGrid;
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();

		// 모델명 세팅
// 		$M.setValue("machine_name", list[0].machine_name);
	});

	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField : "machine_name",
				visible : false,
			},
			{
				dataField : "machine_plant_seq",
				visible : false,
			},
			{
				headerText: "적용기간",
				dataField: "change_dt",
				width : "200",
				style : "aui-left",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText: "판매가격(리스트)",
				dataField: "list_sale_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				headerText: "최저판매가격",
				dataField: "min_sale_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText: "대리점 수수료",
				headerText: "위탁판매점 수수료",
				dataField: "ma_agency_margin_amt",
				dataType : "numeric",
				width : "130",
				style : "aui-right",
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText: "대리점 최저공급가",
				headerText: "위탁판매점 최저공급가",
				dataField: "agency_min_sale_price",
				dataType : "numeric",
				width : "130",
				style : "aui-right",
			},
			{
				headerText: "프로모션가(본사)",
				dataField: "base_pro_sale_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText: "프로모션가(대리점)",
				headerText: "프로모션가(위탁판매점)",
				dataField: "agency_pro_sale_price",
				dataType : "numeric",
				width : "130",
				style : "aui-right",
			},
			{
				headerText: "할인한도",
				dataField: "max_dc_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				headerText: "작성전결",
				dataField: "write_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				headerText: "심사전결",
				dataField: "review_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				headerText: "합의전결",
				dataField: "agree_price",
				dataType : "numeric",
				width : "110",
				style : "aui-right",
			},
			{
				// [14510] '판매가 변경사유' -> '변경사유'로 컬럼헤드 변경 - 김경빈
				headerText: "변경사유",
				dataField: "change_remark",
				width : "200",
				style : "aui-left",
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
		// 그리드 셀 클릭시
		/* AUIGrid.bind(auiGrid, "cellClick", function(event){
			if (event.dataField == "change_dt") {
				var param = {
					"machine_plant_seq" : event.item["machine_plant_seq"],
					"change_dt" : event.item["change_dt"]
				};
				goSearchDetail(param);
			}
		}); */
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	// 저장
	function goSave() {
		var frm = document.main_form;

		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};

		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			self.location.reload();
					}
				}
			);
	}

	// 삭제
	function goRemove() {
		var data = AUIGrid.getGridData(auiGrid);
		var dataArr = [];  // 적요일자 삭제 대상이 있는지 체크하기 위한 배열 선언

		for (var i = 0; i < data.length; i++) {
			dataArr.push(data[i].change_dt);
		}

		// 삭제대상 체크
		if (dataArr.includes($M.getValue("change_dt")) == false) {
			alert("해당 적용일자의 단가목록이 없습니다.");
			$("#change_dt").focus();
			return;
		}

		var param = {
				machine_plant_seq : $M.getValue("machine_plant_seq"),
				change_dt : $M.getValue("change_dt")
		}

		$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), { method : "POST"},
			function(result) {
				if(result.success) {
					self.location.reload();
				};
			}
		);
	}

	function goSearchDetail(param) {
		// machine_plant_seq 없으면 return
		if(param == null) {
			return;
		}

		$M.goNextPageAjax(this_page + "/" + param.machine_plant_seq + "/" + param.change_dt, '', { method : 'get'},
			function(result) {
					if(result.success) {
						var bean = result.bean;
						$M.setValue(bean);
					}
				}
			);
	}

	// 날짜 변경시 input clear 작업
	function fnClear() {
		var setParam = {
				"fee_price" : '',
				"sale_price" : '',
				"write_price" : '',
				"agency_price" : '',
				"review_price" : '',
				"max_dc_price" : '',
				"agree_price" : '',
				"change_remark" : ''
		};

		$M.setValue(setParam);
	}
	</script>

<!--  calDate 동작 에러 이슈로 인한 스타일 지정   -->
	<style>
		#ui-datepicker-div {
			z-index : 99 !important;
		}
	</style>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<!-- <div class="title-wrap">
				<h4>출하단가관리</h4>
			</div> -->
<!-- 상단 폼테이블 -->
 			<%-- <div>
				 <table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="40px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">모델명</th>
							<td colspan="4">
								<input type="text" class="form-control width140px " readonly id="machine_name" name="machine_name" value="${map.machine_name}">
								<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="${inputParam.machine_plant_seq}" >
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">적용일자</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<div class="input-group date-wrap">
											<input type="text" class="form-control border-right-0 essential-bg calDate" id="change_dt" name="change_dt" dateFormat="yyyy-MM-dd" alt="적용일자" value="${inputParam.s_current_dt}" required="required" onChange="javascript:fnClear();">
										</div>
									</div>
								</div>
							</td>
							<th rowspan="4" class="th-skyblue">전<br>결<br>기<br>준<br>가</th>
							<th class="text-right">수수료</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="fee_price" name="fee_price" format="num" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">정상판가</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="sale_price" name="sale_price" format="num" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">작성</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="write_price" name="write_price" format="num" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">대리점가</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="agency_price" name="agency_price" format="num" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">심의</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="review_price" name="review_price" format="num" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">할인한도</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="max_dc_price" name="max_dc_price" format="num" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">합의</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control text-right" id="agree_price" name="agree_price" format="num">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">단가변경사유</th>
							<td colspan="4">
								<input type="text" class="form-control essential-bg" id="change_remark" name="change_remark" alt="단가변경사유"  required="required">
							</td>
						</tr>


					</tbody>
				</table>
			</div> --%>
<!-- /상단 폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<%-- <div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div> --%>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- 하단 폼테이블 -->
			<div>
<!-- 생산발주내역 -->
				<div class="title-wrap mt10">
					<h4>${map.machine_name}</h4>
				</div>

				<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
<!-- /생산발주내역 -->
			</div>
<!-- /하단 폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</div>
</form>
</body>
</html>
