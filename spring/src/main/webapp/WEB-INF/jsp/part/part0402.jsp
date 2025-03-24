<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 수요예측 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();
			fnChangeMajor();
		});
		
		// 매입처조회(와이드)
		function fnSearchClientWide() {
			var param = {
				s_cust_name : $M.getValue("s_cust_name")
			};
			openSearchClientPanel('setSearchClientInfo', 'wide', $M.toGetParam(param));
		} 
		
		function setSearchClientInfo(row) {
			var param = {
				s_cust_no : row.cust_no,
				s_cust_name : row.cust_name
			}
			$M.setValue(param);
		}

		function createAUIGrid() {
			var gridPros = {
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 출력 여부
				showRowAllcheckBox : true,
				showRowNumColumn : true,
				enableSorting : true,
				enableFilter :true,
			};
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "110",
					minWidth : "95",
					filter : {
		                  showIcon : true
		            },
					style : "aui-center aui-popup",
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-left",
					filter : {
		                  showIcon : true
		            },
		            width : "110",
		            minWidth : "95",
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					filter : {
		                  showIcon : true
		            },
		            width : "65",
		            minWidth : "55",
				},
				{
					headerText : "구분",
					dataField : "part_production_name",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "매입처명",
					dataField : "cust_name",
					filter : {
		                  showIcon : true
		            },
		            width : "110",
		            minWidth : "95",
				},
				{
					headerText : "분류",
					dataField : "part_group_cd",
					filter : {
		                  showIcon : true
		            },
		            width : "65",
		            minWidth : "55",
				},
				{
					headerText : "예측량",
					dataField : "final_forecast",
					dataType : "numeric",
					style : "aui-right",
					width : "60",
		            minWidth : "55",
				},
				{
					headerText : "선주문",
					dataField : "preorder_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "60",
		            minWidth : "55",
				},
				{
					headerText : "현재고(ⓕ)",
					dataField : "current_stock",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "부품부재고",
					dataField : "stock_6000",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "총적정재고",
					dataField : "homi_cnt",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "과부족",
					dataField : "over_short",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "안전재고(ⓓ)",
					dataField : "part_safe_stock",
					dataType : "numeric",
					style : "aui-right",
					width : "75",
		            minWidth : "55",
				},
				{
					headerText : "LOT",
					dataField : "part_lot",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				/* {
					headerText : "발주검토일",
					dataField : "reg_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				}, */					
				{
					headerText : "발주중(ⓖ)",
					dataField : "order_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "FCST(ⓐ)",
					dataField : "fcstqty",
					dataType : "numeric",
					style : "aui-right aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return  value == "" || value == null ? "-" : $M.setComma(value);
					},
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "L/T(ⓑ)",
					dataField : "part_pur_day_cnt",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "당해매출",
					dataField : "be0_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "전년매출",
					dataField : "be1_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "전전년매출",
					dataField : "be2_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
				{
					headerText : "3년간총매출",
					dataField : "year3_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "75",
					minWidth : "55",
				},
				{
					headerText : "호환모델건수",
					dataField : "comm_cnt",
					dataType : "numeric",
					style : "aui-center",
					width : "80",
		            minWidth : "80",
		            postfix : "건",
				},
				{
					headerText : "비교판매량",
					dataField : "sale_per",
					style : "aui-center",
					width : "70",
		            minWidth : "70",
		            postfix : "%",
				},
				{
					headerText : "판매고객수",
					dataField : "cust_cnt",
					dataType : "numeric",
					style : "aui-right",
					width : "65",
		            minWidth : "55",
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
			// AUIGrid.setFixedColumnCount(auiGrid, 2);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var poppupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=550, left=0, top=0";
				var param = {
					"part_no" : event.item["part_no"]
				};
				if(event.dataField == 'part_no') {
					$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} else if(event.dataField == 'fcstqty') {
					param["order_qty"] = event.item["order_qty"];
					$M.goNextPage('/part/part0402p03', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		};

		function goExceptPart() {
			var poppupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=550, left=0, top=0";
			$M.goNextPage('/part/part0402p02', "", {popupStatus : poppupOption});
		}

		function goSearch() { 
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_part_production_cd" : $M.getValue("s_part_production_cd"),
				"s_part_group_cd" : $M.getValue("s_part_group_cd"),
				"s_search_condition" : $M.getValue("s_search_condition"),
				"s_not_import_yn" : $M.getValue("s_not_import_yn"),
				"s_long_term_inven_yn" : $M.getValue("s_long_term_inven_yn"),
				"s_not_part_yn" : $M.getValue("s_not_part_yn"),
				"s_suspension_sale_yn" : $M.getValue("s_suspension_sale_yn"),
				"s_cust_no" : $M.getValue("s_cust_no"),
				"s_part_real_check_cd" : $M.getValue("s_part_real_check_cd"),
				"s_major_yn" : $M.getValue("s_major_yn") == "Y" ? "Y" : "N",
				"s_preorder_yn" : $M.getValue("s_preorder_yn") == "Y" ? "Y" : "N",	// 선주문 검색조건 추가
				"s_part_major_type_cd_str" : $M.getValue("s_part_major_type_cd_str"),							// 주요부품 상세검색 추가
				"s_sort_key" : "part_no",
				"s_sort_method" : "asc"
			};
			$M.goNextPageAjax(this_page+"/search", $M.toGetParam(param), {method : 'get', timeout : 60 * 60 * 1000},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		function goPartOrder() {
			alert("발주예약기능 없어짐");
			return false;
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=400, left=0, top=0";
			$M.goNextPage('/part/part0402p01', "", {popupStatus : poppupOption});
		};

		function goExcept() {
			var data = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (data.length == 0) {
				alert("체크된 부품이 없습니다.");
				return false;
			} else {
				if (confirm("제외처리 하시겠습니까?")) {
					var param = {
						part_no_str : $M.getArrStr(data, {key : "part_no"})
					};
					$M.goNextPageAjax(this_page+"/except", $M.toGetParam(param), {method : 'post'},
							function(result) {
								if(result.success) {
									AUIGrid.removeCheckedRows(auiGrid);
									AUIGrid.removeSoftRows(auiGrid);
									AUIGrid.resetUpdatedItems(auiGrid);
								};
							}
					);
				}
			}
		}

		function fnDownloadExcel() {
			  fnExportExcel(auiGrid, "수요예측", {});
		}
		
		// 주요부품 체크유무에 따른 검색조건 추가
		function fnChangeMajor() {
			var majorYn = $("input:checkbox[name='s_major_yn']").is(":checked");
			var fieldArr = ["comm_cnt", "sale_per", "cust_cnt"];
			if(majorYn) {
				$(".searchMajor").removeClass("dpn");
// 				AUIGrid.showColumnByDataField(auiGrid, fieldArr);
			} else {
				$(".searchMajor").addClass("dpn");
				$M.setValue("s_part_major_type_cd_str", "");
				AUIGrid.hideColumnByDataField(auiGrid, fieldArr);
			} 
		}
		
	  	// 기준정보 재생성
	  	function goChangeSave() {
            $M.goNextPageAjax(this_page + "/syncMajorPart", "", {method: "POST", timeout : 60 * 60 * 1000},
                function (result) {
                    if (result.success) {
                        alert("주요부품 기준정보 재생성을 완료하였습니다.");
                        window.location.reload();
                    }
                }
            );
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
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="80px">
							<col width="65px">
							<col width="100px">
							<col width="65px">
							<col width="200px">
							<col width="50px">
							<col width="410px">
							<col width="50px">
							<col width="70px">
						</colgroup>
						<tbody>
								<tr>
									<th>메이커</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
<!-- 											<option value ="">- 전체 -</option> 21.09.10 조회 속도로 인해 일단 주석 처리 -->
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>생산구분</th>
									<td>
										<select class="form-control" id="s_part_production_cd" name="s_part_production_cd">
											<option value="">- 전체 -</option>
											<%-- <c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach> --%>
											<option value="0">외자</option>
											<option value="1">내자</option>
											<option value="3">중고</option>
											<option value="4">분해</option>
										</select>
									</td>
									<th>분류구분</th>
									<td>		
										<div class="form-row inline-pd">
											<div class="col">
												<input type="text" id="s_part_group_cd" name="s_part_group_cd" style="width : 200px";
														easyui="combogrid"
														easyuiname="partGroupCode"
														textfield="code_name"
														multi="N"
														idfield="code" />
											</div>							
										</div>
									</td>
									<td colspan="4" class="pl15">
										<div class="form-row inline-pd">
											<div class="col-auto">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="checkbox" id="s_preorder_yn" name="s_preorder_yn" value="Y">
													<label class="form-check-label" for="s_preorder_yn">선 주문</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="checkbox" id="s_major_yn" name="s_major_yn" value="Y" onchange="javascript:fnChangeMajor();">
													<label class="form-check-label" for="s_major_yn">주요부품</label>
												</div>
											</div>
											<div class="searchMajor dpn col-auto">
												<select class="form-control" id="s_part_major_type_cd_str" name="s_part_major_type_cd_str">
													<option value="">- 전체 -</option>
													<c:forEach items="${codeMap['PART_MAJOR_TYPE']}" var="item">
														<option value="${item.code_value}">${item.code_name}</option>
													</c:forEach>	
												</select>
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>조회조건</th>
									<td colspan="2">
										<select class="form-control" id="s_search_condition" name="s_search_condition">
											<option value="">- 전체 -</option>
											<option value="1">예측량이 있는 자료</option>
											<option value="2">HOMI자료</option>
											<option value="3">출하지급품</option>
											<option value="4">2개월 판매자료</option>
										</select>
									</td>
									<td colspan="3" class="pl15">
										<div class="form-row inline-pd">
											<div class="col-auto">
												<div class="form-check form-check-inline">
													<!-- part_mng_cd 0 -->
													<input class="form-check-input" type="checkbox" id="s_not_import_yn" name="s_not_import_yn" value="Y">
													<label class="form-check-label" for="s_not_import_yn">미수입</label>
												</div>
												<div class="form-check form-check-inline pl10">
													<!-- part_mng_cd 7 -->
													<input class="form-check-input" type="checkbox" id="s_long_term_inven_yn" name="s_long_term_inven_yn" value="Y">
													<label class="form-check-label" for="s_long_term_inven_yn">장기재고</label>
												</div>
												<div class="form-check form-check-inline pl10">
													<!-- part_mng_cd 8 -->
													<input class="form-check-input" type="checkbox" id="s_not_part_yn" name="s_not_part_yn" value="Y">
													<label class="form-check-label" for="s_not_part_yn">비부품</label>
												</div>
												<div class="form-check form-check-inline pl10">
													<!-- part_mng_cd 9 -->
													<input class="form-check-input" type="checkbox" id="s_suspension_sale_yn" name="s_suspension_sale_yn" value="Y">
													<label class="form-check-label" for="s_suspension_sale_yn">매출정지</label>
												</div>
											</div>
										</div>
									</td>
									<th>매입처</th>
									<td colspan="1" >		
										<div class="form-row inline-pd">
											<div class="col-6">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="s_cust_name" name="s_cust_name">
													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch" onclick="javascript:fnSearchClientWide();"></i></button>
												</div>
											</div>
											<div class="col-6">
												<input type="text" class="form-control" readonly id="s_cust_no" name="s_cust_no">
											</div>
											<!-- <div class="col-4">
												<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="goPartOrder();">거래처별 주문상품</button>
											</div> -->
										</div>
									</td>
									<th>실사구분</th>
									<td>
										<select class="form-control" id="s_part_real_check_cd" name="s_part_real_check_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['PART_REAL_CHECK']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
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
                           <div class="left" style="margin-left:50px;">
                               <span style="color: #ff7f00;">※ 주요부품 상태 변경 시 재생성을 해야 수요예측에 표기됩니다.</span>
                           </div>
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
							<button type="button" id="_goExceptPart" class="btn btn-default" onclick="javascript:goExceptPart();">제외품목</button>
							<button type="button" id="_goExcept" class="btn btn-default" onclick="javascript:goExcept();"><i class="material-iconsremove text-default"></i>제외처리</button>
							<button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
						</div>
					</div>
				</div>		
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
	<!-- 산출내역 설명 -->
				<div class="alert alert-secondary mt10">
					<div class="title">
						<i class="material-iconserror font-16"></i>
						산출내역
					</div>
					<div class="row">
						<ul class="col-3">
							<li>ⓐ FCST : 현재전월기준 1년간 출고 수량에 의하여 산출</li>
							<li>ⓑ L/T : 상품코드의 구매일수</li>
							<li>ⓒ = ⓐ FCST X ⓑL/T / 30*1.65</li>
						</ul>
						<ul class="col-3">
							<li>ⓓ 안전재고 : 상품코드의 적정재고</li>
							<li>ⓔ  ROP= ⓒ + ⓓ</li>
							<li>ⓕ 현재고 : 작성시점의 현 재고</li>
						</ul>
						<ul class="col-3">
							<li>ⓖ 발주중 : 발주확정 후 미 입고수량</li>
							<li>ⓗ ORDER = (ⓒ + ⓓ / 2) – (ⓕ + ⓖ)</li>
							<li>최소발주 = ⓐ FCST X 30%</li>
						</ul>
						<ul class="col-3">
							<li>※ 예측량 : ⓗ ORDER이 발주수량보다 작으면 발주단위수량 아니면 ⓗ ORDER올림수량</li>
						</ul>
					</div>						
				</div>
<!-- /산출내역 설명 -->
			</div>
		</div>		
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>