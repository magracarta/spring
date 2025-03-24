<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품CUBE > 부품SET등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
// 			goSearch();
	//			fnInit();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				treeColumnIndex : 5,
				editable : true
			};
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "150", 
					minWidth : "150", 
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								s_search_kind : 'DEFAULT_PART',
								's_warehouse_cd' : $M.getValue("warehouse_cd"),
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				    			's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param, "#auiGrid");
						},
					},
				},
				{
					headerText : "부품명", 
					dataField : "part_name", 
					width : "170", 
					minWidth : "170", 
					style : "aui-left",
					editable : true
				},	
				{ 
					headerText : "수량", 
					dataField : "set_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "60",
					minWidth : "60",
					style : "aui-center aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
 					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
 					      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
					      validator : AUIGrid.commonValidator
					},
					editable : true,
				},
				{ 
					headerText : "VIP가", 
					dataField : "vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
					editable : false,
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var vipAmt = AUIGrid.formatNumber(value, "#,##0");
// 						if(item["seq_depth"] != "1") {
// 							vipAmt = "";
// 						}
// 				    	return vipAmt; 
// 					}
				},
				{ 
					headerText : "합계 VIP가", 
					dataField : "total_vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
					editable : false,
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var vipAmt = AUIGrid.formatNumber(value, "#,##0");
// 						if(item["seq_depth"] != "1") {
// 							vipAmt = "";
// 						}
// 				    	return vipAmt; 
// 					}
				},
				{ 
					headerText : "일반가", 
					dataField : "sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
					editable : false,
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var saleAmt = AUIGrid.formatNumber(value, "#,##0");
// 						if(item["seq_depth"] != "1") {
// 							saleAmt = "";
// 						}
// 				    	return saleAmt; 
// 					}
				},
				{ 
					headerText : "합계 일반가", 
					dataField : "total_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
					editable : false,
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var saleAmt = AUIGrid.formatNumber(value, "#,##0");
// 						if(item["seq_depth"] != "1") {
// 							saleAmt = "";
// 						}
// 				    	return saleAmt; 
// 					}
				},
				{ 
					headerText : "비고", 
					dataField : "set_remark",
					width : "140",
					minWidth : "140",
					style : "aui-left aui-editable",
					editable : true
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn", 
					width : "50",
					minWidth : "50",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGrid);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
								AUIGrid.update(auiGrid);
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
			$("#auiGrid").resize();	
		}
		
		// 행추가 
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");
			var item = new Object();
    		item.part_no = "",
    		item.part_name = "",
    		item.set_qty = 1,
    		item.vip_sale_price = "",
    		item.total_vip_sale_price = "",
    		item.sale_price = "",
    		item.total_sale_price = "",
    		item.set_remark = "",
    		item.removeBtn = "",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}
		
		// 10행 추가
// 		function fnAdd() {
// 			for(var i=0; i<10; i++) {
// 				var item = new Object();
// 				item.seq_no = "",
// 	    		item.part_no = "",
// 	    		item.part_name = "",
// 	    		item.part_unit = "",
// 	    		item.stock_qty = "",
// 	    		item.qty = 1,
// 	    		item.unit_price = "",
// 	    		item.amount = "",
// 	    		item.out_dt = "",
// 	    		item.sale_mi_qty = "",
// 	    		item.remark = "",
// 	    		item.storage_name = "",
// 	    		item.removeBtn = "",
// 	    		item.part_name_change_yn = "N",

// 	    		AUIGrid.addRow(auiGrid, item, 'last');
// 			}
// 		}
		
		// 부품조회
		function goPartList() {
			var param = {
	    			 's_warehouse_cd' : $M.getValue("warehouse_cd"),
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
	    	};
			
			openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
			var params = AUIGrid.getGridData(auiGrid);
			
			var partNo ='';
			var partName ='';
			var unitPrice ='';
			var vipSalePrice ='';
			var vipSaleVatPrice ='';
			var qty = 1;
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.set_qty = qty;
					row.vip_sale_price = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice : rowArr[i].vip_sale_price;
					row.total_vip_sale_price = typeof rowArr[i].vip_sale_price == "undefined" ? vipSaleVatPrice : rowArr[i].vip_sale_price; // vat별도 값 (추후 단가 함수 완료 시 변경)												
					row.sale_price = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price;
					row.total_sale_price = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price;
					row.set_remark = "";
					AUIGrid.addRow(auiGrid, row, 'last');
				}
				// 금액 적용
				fnChangeAmt();
			}
		}
		
		// 금액 변경 메소드
		 function fnChangeAmt() {
			$M.setValue("vip_sale_price", AUIGrid.getNotDeletedColumnValuesSum(auiGrid, "vip_sale_price"));
			$M.setValue("total_vip_sale_price", AUIGrid.getNotDeletedColumnValuesSum(auiGrid, "total_vip_sale_price"));
			$M.setValue("sale_price", AUIGrid.getNotDeletedColumnValuesSum(auiGrid, "sale_price"));
			$M.setValue("total_sale_price", AUIGrid.getNotDeletedColumnValuesSum(auiGrid, "total_sale_price"));
		 }
		
		// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
		function fnGetPartItem(part_no) {
			var item;
			$.each(recentPartList, function(index, row) {
				if(row.part_no == part_no) {
					item = row;
					return false; // 중지
				}
			});
	 		return item;
		 };
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
			switch(event.type) {
 			case "cellEditEndBefore" :
 				if(event.dataField == "part_no") {
					if (event.value == "") {
							return event.oldValue;							
					}
				}
				
 				break;
			case "cellEditEnd" :
				if(event.dataField == "part_no") {
					if (event.value == ""){
						return "";
					}
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					if(item === undefined) {
						AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGrid, {
							part_name : item.part_name,
							set_qty : 1,
							vip_sale_price : item.vip_sale_price,
							total_vip_sale_price : event.item.set_qty * item.vip_sale_price,
							sale_price : item.sale_price,
							total_sale_price : event.item.set_qty * item.sale_price,
						}, event.rowIndex);
					} 
					// 금액 적용
					fnChangeAmt();
			    }
				
				// 수량, 단가 입력 시 금액 계산
				var qty;
				var unitPrice;
				var rowIndex;
				if (event.dataField == "set_qty") {
					qty = event.value;
					rowIndex = event.rowIndex;
	 	            AUIGrid.updateRow(auiGrid, { "vip_sale_price" : event.item.vip_sale_price}, rowIndex);
	 	            AUIGrid.updateRow(auiGrid, { "total_vip_sale_price" : qty * event.item.vip_sale_price}, rowIndex);
	 	            AUIGrid.updateRow(auiGrid, { "sale_price" : event.item.sale_price}, rowIndex);
	 	            AUIGrid.updateRow(auiGrid, { "total_sale_price" : qty * event.item.sale_price}, rowIndex);
	 	       		// 금액 적용
					fnChangeAmt();
				}
				break;
			} 
		};
			
		// 저장
		function goSave() {
			if($M.validation(document.main_form) == false) {
				return false;
			}
			
			var rowCount = AUIGrid.getRowCount(auiGrid);

			if(rowCount == 0) {
				alert("구성 부품이 없습니다.");
				return false;
			};
			
			var gridData = AUIGrid.getGridData(auiGrid);
			var cnt = 0;
			
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].part_no != "") {
					cnt++;
				}
			}

			if(cnt == 0) {
				alert("구성 부품을 입력해주세요.");
				return false;
			}
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var gridForm = fnChangeGridDataToForm(auiGrid);
			
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridForm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			opener.goSearch();
		    			fnClose();
					};
				}
			); 
		}

		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="warehouse_cd" id="warehouse_cd" value="${SecureUser.warehouse_cd != '' ? SecureUser.warehouse_cd : SecureUser.org_code}"><!-- 로그인한 사용자의 조직코드 -->
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
           <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<h4>SET등록</h4>			
			</div>	
<!-- SET등록 -->					
            <table class="table-border">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right essential-item">SET명</th>
                        <td colspan="3">
                            <input type="text" class="form-control essential-bg" id="set_name" name="set_name" alt="SET명" required="required">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">VIP가</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="vip_sale_price" name="vip_sale_price" value="0" format="decimal">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                        <th class="text-right">합계 VIP가</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="total_vip_sale_price" name="total_vip_sale_price" value="0" format="decimal">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                    </tr>
                     <tr>
                        <th class="text-right">일반가</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="sale_price" name="sale_price" value="0" format="decimal">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                        <th class="text-right">합계 일반가</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="total_sale_price" name="total_sale_price" value="0" format="decimal">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">비고</th>
                        <td colspan="3">
                            <textarea class="form-control" style="height: 70px;" id="remark" name="remark"></textarea>
                        </td>
                    </tr>
                </tbody>
            </table>
<!-- /SET등록 -->	
<!-- 구성품 -->
            <div class="title-wrap mt10">
                <h4>구성품</h4>
                <div class="btn-group">
                    <div class="right">
                    	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                    </div>
                </div>
            </div>
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
<!-- /구성품 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">						
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