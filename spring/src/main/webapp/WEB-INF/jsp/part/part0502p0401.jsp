<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > HOMI관리 > HOMI관리상세 > 미사용 부품 회수
-- 작성자 : 박예진
-- 최초 작성일 : 2021-05-21 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	var checkGridData;
	
	$(document).ready(function() {
		createAUIGrid();
	});

	//조회
	function goSearch() { 
		var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_warehouse_cd : $M.getValue("warehouse_cd"),
				s_homi_yn : $M.getValue("s_homi_yn") == "N" ? "N" : "Y",
				s_current_under_safe : $M.getValue("s_current_under_safe"),
				s_out_mng_yn : $M.getValue("s_out_mng_yn"),
				s_sort_key : "part_no",
				s_sort_method : "asc",
				s_current_stock_yn : $M.getValue("s_current_stock_yn") == "Y" ? "Y" : "N",
		};

		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
		);		
	} 
	
	function createAUIGrid() {
		var gridPros = {
				showRowCheckColumn : true,
				showRowAllcheckBox : true,
				// rowIdField 설정
				rowIdField : "_$uid",
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// rowNumber 
				showRowNumColumn: true,
				editable : true,
		};
		var columnLayout = [
			{
				headerText : "부품번호", 
				dataField : "part_no", 
				width : "160", 
				minWidth : "160", 
				style : "aui-left",
				editable : false
			},
			{ 
				headerText : "부품명", 
				dataField : "part_name", 
				width : "210", 
				minWidth : "210", 
				style : "aui-left   aui-popup",
				editable : false
			},
			{ 
				headerText : "VIP판매가", 
				dataField : "vip_sale_price", 
				width : "90", 
				minWidth : "90", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "일반판매가", 
				dataField : "sale_price", 
				width : "90", 
				minWidth : "90", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "전체재고", 
				dataField : "all_qty", 
				width : "60", 
				minWidth : "60", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "본사재고", 
				dataField : "base_stock",  
				width : "60", 
				minWidth : "60", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "센터재고", 
				dataField : "center_stock",  
				width : "60", 
				minWidth : "60", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "적정재고", 
				dataField : "safe_stock",  
				width : "60", 
				minWidth : "60", 
				style : "aui-right aui-popup",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "과부족", 
				dataField : "under_over", 
				width : "60", 
				minWidth : "60", 
				style : "aui-right aui-popup",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "보유율(%)", 
				dataField : "stock_rate",  
				width : "65", 
				minWidth : "65", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
 			{ 
				headerText : "미사용부품회수", 
				dataField : "qty",  
				width : "90", 
				minWidth : "90",  
				style : "aui-right aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				      // 에디팅 유효성 검사
				     validator : function(oldValue, newValue, item) {
					}
				}
			},
 			{ 
				headerText : "입고예정수량", 
				dataField : "order_qty",  
				width : "85", 
				minWidth : "85", 
				style : "aui-right",
				editable : false,
				dataType : "numeric",
			},
			{ 
				headerText : "비고", 
				dataField : "part_remark",  
				width : "170", 
				minWidth : "170", 
				style : "aui-left",
				editable : false
			}
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			var param = {
					"s_part_no" : event.item["part_no"],
					"part_no" : event.item["part_no"],
					"s_warehouse_cd" :  $M.getValue("warehouse_cd")
				};
			
			var popupOption = "";
			
			if(event.dataField == 'part_name') {
				$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : popupOption});
			} else if(event.dataField == 'safe_stock') {
				$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
			}else if(event.dataField == 'under_over') {
				$M.goNextPage('/part/part0502p03' , $M.toGetParam(param), {popupStatus : popupOption});
			}
		}); 

	}

	function fnDownloadExcel() {
	  fnExportExcel(auiGrid, "HOMI관리상세");
	}
	
	
// 	function fn_validCheck(obj) {
// 		if(obj.id == "s_out_mng_yn"){
								
// 			if($M.getValue("s_out_mng_yn") == "Y" ){
// 				$("#s_homi_yn").prop("checked", false);
// 				$("#s_current_under_safe").prop("checked", false);
// 			}

// 		}
// 		else {
// 			$("#s_out_mng_yn").prop("checked", false);
// 		}
// 	}
	
	
	// 부품회수
	function goRecoveryPart() {
	    var editedRowItems = AUIGrid.getEditedRowItems(auiGrid);
	    var gridAllList = AUIGrid.getGridData(auiGrid);
	    var checkedRowItems = AUIGrid.getCheckedRowItemsAll(auiGrid);

	    if(checkedRowItems.length <= 0) {
		    alert("미사용 부품회수할 부품을 체크해주세요.");
		    return;
		}

		
		for (var i = 0; i < gridAllList.length; i++) {			
		   for (var j = 0; j < checkedRowItems.length; j++) {	
			   
			   if (gridAllList[i].part_no == checkedRowItems[j].part_no){
					// 부품회수 요청수량이 1보다 작은경우 
					if( checkedRowItems[j].qty <= 0) {					

						alert("체크된 정보의 미사용 부품회수 수량을 입력해주세요.");		
						AUIGrid.showToastMessage(auiGrid, i, 10, "체크된 정보의 미사용 부품회수 수량을 입력해주세요.");
						return;
					}			   
			   }			  				
		    }		
		}
 
		var frm = document.main_form;
		frm = $M.toValueForm(frm);
		
		var gridForm = fnCheckedGridDataToForm(auiGrid);
		// grid form 안에 frm copy
		$M.copyForm(gridForm, frm);
		
		$M.goNextPageAjaxMsg("이동요청명세를 작성 하시겠습니까?", this_page + "/save", gridForm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
// 	    			AUIGrid.removeSoftRows(auiGrid);
// 	    			AUIGrid.resetUpdatedItems(auiGrid);
	    			goSearch();
				}
			}
		); 
	}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="warehouse_cd" name="warehouse_cd" value="${inputParam.warehouse_cd}">
<input type="hidden" id="homi_dt" name="homi_dt" value="${inputParam.homi_dt}">
<input type="hidden" id="seq_no" name="seq_no" value="${inputParam.seq_no}">
<input type="hidden" id="part_trans_req_type_cd" name="part_trans_req_type_cd" value="HOMI">
<input type="hidden" id="complete_yn" name="complete_yn" value="Y">

<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- <!-- 타이틀영역 -->
<!--         <div class="main-title"> -->
<%--             <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
<!--         </div> -->
<!-- <!-- /타이틀영역 -->
        <div class="content-wrap">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table table-fixed">
							<colgroup>
								<col width="80px">
								<col width="260px">
								<col width="60px">
								<col width="100px">
								<col width="480px">								
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>이동처리기간</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${inputParam.s_start_dt}" required="required" alt="시작일">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${inputParam.s_end_dt}" required="required" alt="종료일">
												</div>
											</div>
										</div>	
									</td>
									<th>관리센터</th>
									<td>
										[ ${warehouse_name} ]
									</td>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_homi_yn" id="s_homi_yn"  value="N" checked="checked">
											<label for="s_homi_yn" class="form-check-label">HOMI 지정품 제외</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_current_under_safe" id="s_current_under_safe" value="Y">
											<label for="s_current_under_safe" class="form-check-label">센터재고 &gt; 적정재고</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_out_mng_yn" id="s_out_mng_yn" value="Y">
											<label for="s_out_mng_yn" class="form-check-label">출하지급품</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_current_stock_yn" id="s_current_stock_yn" value="Y">
											<label for="s_current_stock_yn" class="form-check-label">센터재고 0포함</label>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>	
								</tr>										
							</tbody>
						</table>	
			</div>
<!-- /검색조건 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->			
<!-- 검색결과 -->
			<div id="auiGrid" class="mt10" style="margin-top: 5px; width: 100%;height: 400px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>