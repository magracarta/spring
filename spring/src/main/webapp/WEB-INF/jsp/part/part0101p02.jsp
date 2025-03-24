<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품조회 > 부품재고조회 > null > 입/출고 내역
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var dataFieldName = []; // 펼침 항목(create할때 넣음)
	
// 	var checkPage = "${inputParam.checkPage}"
		$(document).ready(function() {
			createAUIGridThird();
			
			fnInitDate();
			initInfo()
			
			if("${inputParam.warehouse_cd}" != "") {
				$M.setValue("s_warehouse_cd", "${inputParam.warehouse_cd}");
			};
			
			if("${inputParam.warehouse_cd}" == "" && "${SecureUser.warehouse_cd}" == "6000") {
				$M.setValue("s_warehouse_cd", "");
			}

			// 2.9차 (Q&A 13341) 재고정리버튼 부품부만 보이도록 처리. 20220620 김상덕
			if ("${page.fnc.F00364_001}" == "Y") {
				$("#applyPartStockBtn").removeClass("dpn");
			}

			// Q&A 15194 기본조회 제거. 20221012 김상덕
			// goSearch();
			
		});
		
		function fnInitDate() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
			
		}
		
		
		function initInfo() {

			if("${inputParam.s_assign_start_dt}" != "") {
				$M.setValue("s_start_dt", "${inputParam.s_assign_start_dt}");			
			};
			
			if("${inputParam.s_assign_end_dt}" != "") {
				$M.setValue("s_end_dt", "${inputParam.s_assign_end_dt}");			
			};
	
			if("${inputParam.s_part_move_type_cd_in}" == 'N') {
				$("input:checkbox[id='s_part_move_type_cd_in']").prop("checked", false);
			} else {
				$("input:checkbox[id='s_part_move_type_cd_in']").prop("checked", true);
			};
			
			if("${inputParam.s_part_move_type_cd_out}" == 'N') {
				$("input:checkbox[id='s_part_move_type_cd_out']").prop("checked", false);
			} else {
				$("input:checkbox[id='s_part_move_type_cd_out']").prop("checked", true);
			}
			if("${inputParam.s_part_move_type_cd_move}" == 'N') {
				$("input:checkbox[id='s_part_move_type_cd_move']").prop("checked", false);
			} else {
				$("input:checkbox[id='s_part_move_type_cd_move']").prop("checked", true);
			}
			
			if("${inputParam.s_cost_yn}" == 'Y') {
				$("#s_cost_yn").val("Y").attr("selected", "selected");				
			};
			
		}
	
		//조회
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["s_start_dt", "s_end_dt"]})==false) {
				return;
			};
			
			var part_in = $M.nvl($M.getValue("s_part_move_type_cd_in"), "");
			var part_out = $M.nvl($M.getValue("s_part_move_type_cd_out"), "");
			var part_move = $M.nvl($M.getValue("s_part_move_type_cd_move"), "");
			
			
			
			if(part_in == "" && part_out == "" && part_move == "") {
				alert("입/출고, 이동 구분 값을 체크해 주세요. ");
				return;
			}
				
			var url = this_page + '/search';
// 			if(checkPage == "Y") {
// 				url = this_page + '/searchPartInoutStock';
// 			}

			var param = {
					"part_no" 					: "${inputParam.part_no}",
					"s_start_dt" 				: $M.getValue("s_start_dt"),
					"s_end_dt" 					: $M.getValue("s_end_dt"),
					"s_warehouse_cd"	 		: $M.getValue("s_warehouse_cd"),
					"s_part_move_type_cd_in" 	: $M.getValue("s_part_move_type_cd_in"), 
					"s_part_move_type_cd_out" 	: $M.getValue("s_part_move_type_cd_out"), 
					"s_part_move_type_cd_move" 	: $M.getValue("s_part_move_type_cd_move"), 
					"s_cost_yn" 				: $M.getValue("s_cost_yn")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(url, $M.toGetParam(param), {method : 'get'},
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
						$("#sum_qty").text(result.qty_map.sum_qty);
						var beforeQty = result.qty_map.before_qty;
						$("#before_qty").text($M.setComma(beforeQty));

						var gridData = AUIGrid.getGridData(auiGrid);
						
						if(gridData.length > 0) {
							var qty = beforeQty + gridData[0].in_qty - gridData[0].out_qty + gridData[0].trans_in_qty - gridData[0].trans_out_qty;
							var gridInQty = 0;
							var gridOutQty = 0;
							var gridTransInQty = 0;
							var gridTransOutQty = 0;
							AUIGrid.updateRow(auiGrid, { "stock_qty" : qty}, 0);
							for(var i = 1; i < gridData.length; i++) {
								gridInQty = gridData[i].in_qty;
								gridOutQty = gridData[i].out_qty;
								gridTransInQty = gridData[i].trans_in_qty;
								gridTransOutQty = gridData[i].trans_out_qty;
								qty = qty + gridInQty - gridOutQty + gridTransInQty - gridTransOutQty;
								AUIGrid.updateRow(auiGrid, { "stock_qty" : qty}, i);
							}
						}

						var qty1 = AUIGrid.getColumnValues(auiGrid, "in_qty");
						var qty2 = AUIGrid.getColumnValues(auiGrid, "out_qty");
						var qty3 = AUIGrid.getColumnValues(auiGrid, "trans_in_qty");
						var qty4 = AUIGrid.getColumnValues(auiGrid, "trans_out_qty");
// 						var qty5 = AUIGrid.getColumnValues(auiGrid, "stock_qty");
						
						var gridDataQty = AUIGrid.getGridData(auiGrid);
						var length = gridDataQty.length;
						var stockQty = 0;
						
						if(length > 0) {
							stockQty = gridDataQty[length-1].stock_qty;
						} else {
							stockQty = $M.setComma(beforeQty);
						}
						
						var inQty = sum(qty1);
						var outQty = sum(qty2);
						var transInQty = sum(qty3);
						var transOutQty = sum(qty4);
// 						var stockQty = sum(qty5);
						
						$("#in_qty").text($M.setComma(inQty));
						$("#out_qty").text($M.setComma(outQty));
						$("#trans_in_qty").text($M.setComma(transInQty));
						$("#trans_out_qty").text($M.setComma(transOutQty));
						$("#sum_qty").text($M.setComma(stockQty));
						
					}
				;
			});
		}
		
		// 단가 컬럼 sum
		function sum(array) {
		  var result = 0.0;

		  for (var i = 0; i < array.length; i++)
		    result += array[i];

		  return result;
		}
		
		function createAUIGridThird() {
			var gridPros = {
					// rowIdField 설정
					rowIdField : "$_uid",
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// rowNumber 
					showRowNumColumn: true,
					editable : false,
					showEditedCellMarker : false
			};
			var columnLayout = [
				{
					headerText : "처리사항",
					children : [
						{
							dataField : "part_seq_dt",
							headerText : "처리일",
							width : "10%", 
							dataType : "date",
							formatString : "yyyy-mm-dd",
							style : "aui-center",
						}, 
						{
							dataField : "part_seq_no",
							headerText : "처리번호",
							width : "13%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(${page.add.AVG_PRICE_SHOW_YN eq 'Y'}) {
									return "aui-popup";
								} else if(${page.add.AVG_PRICE_SHOW_YN ne 'Y'} && item.gubun == "02") {
									return null;
								} else {
									return "aui-popup";
								}
							},
						},
						{
							headerText : "구분",
							dataField : "part_gubun",
							width : "6%", 
							style : "aui-center",
						},
						{
							dataField : "part_cust_name",
							headerText : "고객명",
							width : "10%", 
							style : "aui-center",
						},
						{
							dataField : "part_trans_mark",
							headerText : "업체명",
							style : "aui-center",
						},
						// 2021.07.15 (SR:11355) 모델명 추가요청 - 황빛찬
						{
							dataField : "machine_name",
							headerText : "모델명",
							style : "aui-center",
							width : "80",
							headerStyle : "aui-fold",
						},
						{
							dataField : "body_no",
							headerText : "차대번호",
							style : "aui-center",
							width : "140",
							headerStyle : "aui-fold",
						},
						{
							dataField : "op_hour",
							headerText : "가동시간",
							style : "aui-center",
							width : "100",
							headerStyle : "aui-fold",
						}
					]
				}, 
				{
					headerText : "매입매출",
					children : [
						{
							dataField : "in_qty",
							headerText : "입고",
							width : "6%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center",
						}, 
						{
							dataField : "out_qty",
							headerText : "출고",
							width : "6%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center",
						}
					]
				}, 
				{
					headerText : "창고이동",
					children : [
						{
							dataField : "trans_in_qty",
							headerText : "입고",
							width : "6%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center",
						}, 
						{
							dataField : "trans_out_qty",
							headerText : "출고",
							width : "6%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center",
						}
					]
				}, 
				{ 
					headerText : "재고", 
					dataField : "stock_qty", 
					width : "6%", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{ 
					headerText : "금액", 
					dataField : "part_amt", 
					width : "10%", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var price = $M.setComma(value);
						// 권한자가 아닐 시 매입전표는 금액 0원으로 보이게 수정 20.12.14 by 박예진
						if(${page.add.AVG_PRICE_SHOW_YN ne 'Y'} && item.gubun == "02") {
							price = 0;
						}
						return price;
					},
					
				},
				{ 
					headerText : "처리자", 
					dataField : "mem_name", 
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "구분", 
					dataField : "gubun", 
					visible : false
				},
				{ 
					headerText : "구분", 
					dataField : "machine_lc_no", 
					visible : false
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var popupOption = "";
				var param = {};
				// 금액도 있으므로 권한자만.
				if(event.dataField == "part_seq_no") {
					if(event.item["gubun"] == "창고") {
						param.part_trans_no = event.item["part_seq_no"];
						$M.goNextPage('/part/part0202p03', $M.toGetParam(param), {popupStatus : popupOption});
						
					} else if(event.item["gubun"] == "조정") {
						param.part_adjust_no = event.item["part_seq_no"];
						$M.goNextPage('/part/part0505p01', $M.toGetParam(param), {popupStatus : popupOption});
						
					} else if(event.item["gubun"] == "10") {
						// 장비 입고 시
						param.machine_lc_no = event.item["machine_lc_no"];
						$M.goNextPage('/serv/serv0201p02', $M.toGetParam(param), {popupStatus : popupOption});
					} else if(event.item["gubun"] == "07" || event.item["gubun"] == "05" || event.item["gubun"] == "08") {
						param.inout_doc_no = event.item["part_seq_no"];
						$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : popupOption});
						
					} else if(event.item["gubun"] == "CUBE") {
						param.part_cube_no = event.item["part_seq_no"];
						$M.goNextPage('/part/part0703p02', $M.toGetParam(param), {popupStatus : popupOption});
					}
					if(event.item["gubun"] == "02") {
						if(${page.add.AVG_PRICE_SHOW_YN eq 'Y'}) {
							param.inout_doc_no = event.item["part_seq_no"];
							$M.goNextPage('/part/part0302p01', $M.toGetParam(param), {popupStatus : popupOption});
							
						}
					}
				}
			});	
			$("#auiGrid").resize();
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
		}
		
		//팝업 끄기
		function fnClose() {
			if('${inputParam.tap_type}' == '') {
				fnClose2();
			} else {
				topClose();
			}
		}
		
		function fnClose2() {
			window.close();
		}
		function topClose() {
			top.fnClose();
		}
	
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "입출고내역", exportProps);
	    }
		
		// 2021.07.15 (SR:11355) 모델명 추가요청 - 황빛찬
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}
		
		function show() {
			document.getElementById("machine_operation").style.display="block";
		}
		function hide() {
			document.getElementById("machine_operation").style.display="none";
		}
		
		// 재고정리
		function goApplyPartStock() {
            var msg = "조회시작월부터 재고를 정리하시겠습니까?";
            
            var param = {
            		"part_no_str" : "${inputParam.part_no}",
            		"start_mon" : $M.getValue("s_start_dt").substring(0, 6)
            }
            
            $M.goNextPageAjaxMsg(msg, "/util/syncPartStock", $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    if (result.success) {
                    	goSearch();
                    }
                }
            );
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <c:if test="${empty inputParam.tap_type}">
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        </c:if>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 검색영역 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="260px">
						<col width="50px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="190px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>조회기간</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="" required="required" alt="시작일">
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${inputParam.s_end_dt}" required="required" alt="종료일">
										</div>
									</div>
									<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
										<jsp:param name="st_field_name" value="s_start_dt"/>
										<jsp:param name="ed_field_name" value="s_end_dt"/>
										<jsp:param name="click_exec_yn" value="Y"/>
										<jsp:param name="exec_func_name" value="goSearch();"/>
									</jsp:include>
								</div>
							</td>
							<th>창고구분</th>
							<td>
							<select class="form-control" name="s_warehouse_cd" id="s_warehouse_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['WAREHOUSE']}"><c:if test="${item.code_value ne '5110' }">
									<option value="${item.code_value}" ${item.code_value == (SecureUser.warehouse_cd != "" ? SecureUser.warehouse_cd : SecureUser.org_code) ? 'selected' : 'item.code_value' }>${item.code_name}</option></c:if>
								</c:forEach>
							</select>
							</td>
							<th>유무상</th>
							<td>
								<select class="form-control" name="s_cost_yn" id="s_cost_yn">
									<option value="">- 전체 -</option>
									<option value="Y">유상</option>
									<option value="N">무상</option>
								</select>	
							</td>
							<td class="pl15">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_part_move_type_cd_in" name="s_part_move_type_cd_in" value="Y" checked="checked">
									<label class="form-check-label" for="s_part_move_type_cd_in">입고</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_part_move_type_cd_out" name="s_part_move_type_cd_out" value="Y" checked="checked">
									<label class="form-check-label" for="s_part_move_type_cd_out">출고</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_part_move_type_cd_move" name="s_part_move_type_cd_move" value="Y" checked="checked">
									<label class="form-check-label" for="s_part_move_type_cd_move">이동</label>
								</div>
							</td>							
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								<div class="form-check form-check-inline" style="margin-left:30px;">
									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
								</div>
								<span id="applyPartStockBtn" class="bd0 dpn">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goApplyPartStock();">재고정리</button>
									<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i>
								</span>				
							<!-- 마우스 오버시 레이어팝업 -->
								<div class="con-info" id="machine_operation" style="max-height: 500px; left: 68%; width: 245px; display: none; top:50px;">
									<ul class="">
										<ol style="color: #666;">&nbsp;재고정리 버튼 클릭 시</ol>
										<ol style="color: #666;">&nbsp;조회시작월부터 현재월까지의 재고를 정리</ol>
									</ul>
								</div>
							<!-- /마우스 오버시 레이어팝업 -->	
							</td>			
						</tr>										
					</tbody>
				</table>					
			</div>
<!-- /검색영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnDownloadExcel();">엑셀다운로드</button>
				</div>
			</div>
<!-- 그리드영역 -->
			<div>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
			</div>
<!-- /그리드영역 -->
<!-- 합계그룹 -->
			<div class="row inline-pd mt10">
				<div class="col" style="width: 8%;">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">이월</th>
								<td class="text-right td-gray" id="before_qty" name="before_qty">0</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col" style="width: 8%;">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">입고</th>
								<td class="text-right td-gray" id="in_qty" name="in_qty">0</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col" style="width: 8%;">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">출고</th>
								<td class="text-right td-gray" id="out_qty" name="out_qty">0</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col" style="width: 8%;">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">이동입고</th>
								<td class="text-right td-gray" id="trans_in_qty" name="trans_in_qty">0</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col" style="width: 8%;">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">이동출고</th>
								<td class="text-right td-gray" id="trans_out_qty" name="trans_out_qty">0</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col" style="width: 8%;">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">잔고</th>
								<td class="text-right td-gray" id="sum_qty" name="sum_qty">0</td>
							</tr>
						</tbody>
					</table>
				</div>				
			</div>
<!-- /합계그룹 -->
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
</form>
</body>
</html>