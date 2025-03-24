<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서 간편등록(스탭2 지급품확인)
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<script type="text/javascript">
	
	$(document).ready(function() {
		createAUIGridForOptAndAttach();
	});

	//그리드생성
	function createAUIGridForOptAndAttach() {
		// 그리드 생성_ 기본제공품(화면에 안보임)
		var columnLayoutBasic = [
			{
				dataField : "basic_item_name"
			},
			{
				dataField : "basic_qty"
			},
			{
				dataField : "basic_machine_name"
			},
			{
				dataField : "basic_seq_no"
			}
		]
		auiGridBasic = AUIGrid.create("#auiGridBasic", columnLayoutBasic, {});
		AUIGrid.setGridData(auiGridBasic, []);
		
		
		//그리드 생성 _ 선택사항
		var gridProsOption = {
			fillColumnSizeMode : false,
			rowIdField : "option_part_no",
			headerHeight : 20,
			rowHeight : 11, 
			footerHeight : 20,
		};
		var columnLayoutOption = [
			{ 
				headerText : "부품번호", 
				dataField : "option_part_no", 
				width : "20%", 
				style : "aui-center",
			},
			{ 
				headerText : "부품명", 
				dataField : "option_part_name", 
				style : "aui-left",
			},
			{ 
				headerText : "단위", 
				dataField : "option_unit", 
				width : "10%", 
				style : "aui-center",
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					return value == null || value == "" ? "-" : value;
				}
			},
			{ 
				headerText : "구성수량", 
				dataField : "option_qty", 
				width : "10%", 
				style : "aui-center",
			},
			{
				dataField : "option_machine_name",
				visible : false
			}
		];
		auiGridOption = AUIGrid.create("#auiGridOption", columnLayoutOption, gridProsOption);
		AUIGrid.setGridData(auiGridOption, []);
		
		//그리드 생성 _ 어테치먼트
		var gridProsAttach = {
			rowIdField : "attach_part_no",
			headerHeight : 20,
			rowHeight : 11, 
			footerHeight : 20,
			fillColumnSizeMode : false,
			rowStyleFunction : function(rowIndex, item) {
				 if(item.attach_check_yn == "Y") {
				  	return "aui-row-highlight";
				 }
				 return "";
			}
		};
		var columnLayoutAttach = [
			{ 
				headerText : "구분", 
				dataField : "gubun", 
				width : "10%", 
				style : "aui-center",
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					if (item.attach_base_yn == "Y") {
						return "기본옵션";
					} else {
						return "추가옵션";
					} 
				}
			},
			{
				dataField : "attach_base_yn",
				visible : false
			},
			{ 
				headerText : "선택", 
				dataField : "attach_check_yn", 
				width : "10%", 
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			},
			{ 
				headerText : "부품번호", 
				dataField : "attach_part_no", 
				width : "20%", 
				style : "aui-center",
			},
			{ 
				headerText : "부품명", 
				dataField : "attach_part_name", 
				width : "30%", 
				style : "aui-left",
			},
			{ 
				headerText : "수량", 
				dataField : "attach_qty", 
				style : "aui-center"
			},
			{ 
				headerText : "전략가",
				dataField : "attach_part_amt",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{
				dataField : "attach_machine_name",
				visible : false
			}
		];
		auiGridAttach = AUIGrid.create("#auiGridAttach", columnLayoutAttach, gridProsAttach);
		AUIGrid.bind(auiGridAttach, "cellEditEnd", function(event) {
			if (event.dataField == "attach_check_yn") {
				if (event.value == 'Y') {
					var param = {
						"attach_machine_plant_seq": event.item.attach_machine_plant_seq,
						"attach_part_no" : event.item.attach_part_no,
						"attach_part_amt" : event.item.attach_part_amt
					};

					$M.goNextPageAjax("/sale/sale0101p01/attach/price/check", $M.toGetParam(param), {method : 'GET'},
						function(result) {
							if(result.success) {
								if (result.changeYn == 'Y') {
									alert("선택하신 부품의 가격이 변동되었습니다.\n수정시 변경된 금액이 반영됩니다.");
									AUIGrid.updateRow(auiGridAttach, { "attach_part_amt" : result.result_part_amt}, event.rowIndex);
								}

								var amt = $M.toNum($M.getValue("attach_amt"));
								var attachPrice = $M.toNum(result.result_part_amt);
								var discount = $M.toNum($M.getValue("discount_amt"));
								var salePrice = $M.toNum($M.getValue("sale_price"));
								var calcPrice = 0;
								if (event.value == "N") {
									calcPrice = amt-attachPrice;
									$M.setValue("sale_amt", amt-attachPrice);
								} else {
									calcPrice = amt+attachPrice;
									$M.setValue("attach_amt", amt+attachPrice);
								};
								$M.setValue("sale_amt", salePrice+calcPrice-discount);
								$M.setValue("attach_amt", calcPrice);
								fnChangePrice();
							}
						}
					);
				} else {
					var amt = $M.toNum($M.getValue("attach_amt"));
					var attachPrice = $M.toNum(event.item.attach_part_amt);
					var discount = $M.toNum($M.getValue("discount_amt"));
					var salePrice = $M.toNum($M.getValue("sale_price"));
					var calcPrice = 0;
					if (event.value == "N") {
						calcPrice = amt-attachPrice;
						$M.setValue("sale_amt", amt-attachPrice);
					} else {
						calcPrice = amt+attachPrice;
						$M.setValue("attach_amt", amt+attachPrice);
					};
					$M.setValue("sale_amt", salePrice+calcPrice-discount);
					$M.setValue("attach_amt", calcPrice);
					fnChangePrice();
				}
			}
		});
		AUIGrid.setGridData(auiGridAttach, []);
	}

	// 옵션변경
	function fnChangeOpt() {
		var opt = $M.getValue("opt_code");
		var tempOptList = [];
		for (var i = 0; i < optList.length; ++i) {
			if (optList[i].opt_code == opt) {
				tempOptList = optList[i].list;
			}
		}
		AUIGrid.setGridData("#auiGridOption", tempOptList);
	}
	
	// 기본지급품 조회
	function goItemDetailPopup() {
		var param = {
			machine_plant_seq : $M.getValue("machine_plant_seq")
		}
		var poppupOption = "";
		$M.goNextPage('/sale/sale0101p02', $M.toGetParam(param), {popupStatus : poppupOption});
	}
</script>
<div class="step-title">
	<span class="step-num">step02</span> <span class="step-title">지급품확인</span>
</div>
<ul class="step-info">
	<li>지급품을 확인 또는 추가를 하신 후 계속 진행하시기 바랍니다.</li>
</ul>
<table class="table-border">
	<colgroup>
		<col width="">
		<col width="">
		<col width="">
		<col width="">
	</colgroup>
	<thead>
		<tr>
			<th>고객명</th>
			<th>휴대폰</th>
			<th>모델명</th>
			<th>출하희망일</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="text-center cust_name_view"></td>
			<td class="text-center hp_no_view"></td>
			<td class="text-center machine_name_view"></td>
			<td class="text-center receive_plan_dt_view"></td>
		</tr>
	</tbody>
</table>

<!-- 선택사항 -->
<div class="title-wrap mt10">
	<h4>선택사항</h4>
	<div class="btn-group">
		<div class="right">
			<select name="opt_code" id="opt_code" style="height: 24px; display: none;" onchange="fnChangeOpt()"></select>
		</div>
	</div>
</div>
<div id="auiGridOption" style="margin-top: 5px; height: 70px;"></div>
<!-- /선택사항 -->
<!-- 어테치먼트 -->
<div class="title-wrap mt10">
	<h4>옵션관리</h4>
</div>
<div id="auiGridAttach" style="margin-top: 5px; height: 150px;"></div>
<!-- /어테치먼트 -->
<!-- 기본지급품목 -->
<div class="title-wrap mt10">
	<h4>기본지급품목</h4>
	<div class="btn-group">
		<div class="right">
			<button type="button" class="btn btn-default" onclick="javascript:goItemDetailPopup();" id="basicDtlBtn" style="display: none;">기본지급품 상세</button>
		</div>
	</div>
</div>

<!-- /그리드 타이틀, 컨트롤 영역 -->

<!-- 기본지급품목내역 -->
<div class="boxing vertical-line mt5" id="basicItemList" style="height: 33px;"></div>
<div class="btn-group mt10">
	<div class="right">
		<button type="button" class="btn btn-md btn-info" style="width: 50px;" onclick="javascript:fnCompleteStep(2)">다음</button>
	</div>
</div>