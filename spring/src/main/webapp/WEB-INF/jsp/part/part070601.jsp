<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 출하시 지급품 관리 > 출하지급품관리 > null
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 15:38:15
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGridFirst();
			var total_cnt_first = AUIGrid.getRowCount(auiGridFirst);
			$("#total_cnt_first").html(total_cnt_first);
		});
		
		function goSave() {
			var validation = isValid();
			if(!validation) {	return;	}
			var removedItems = AUIGrid.getRemovedItems(auiGridRight);
			if(removedItems.length > 0) {
				var rowItem='';
				var idx='';
				for(i=0; i<removedItems.length; i++) {
					rowItem = removedItems[i];
					idx = AUIGrid.getRowIndexesByValue(auiGridRight, "_$uid", rowItem._$uid);
					AUIGrid.restoreSoftRows(auiGridRight, idx); 
					AUIGrid.updateRow(auiGridRight, {
						use_yn : "N"
					}, idx
					);
				}
			}
			var frm = fnChangeGridDataToForm(auiGridRight);
			if(fnGetUpdatedItemsCnt(auiGridRight) == 0) {
				alert(msg.alert.data.noChanged);
				return;
			}
// 			var s_machine_name = $M.getValue("hidMchNm");	
			var machine_plant_seq = $M.getValue("machine_plant_seq");	
			$M.goNextPageAjaxSave(this_page + "/" + machine_plant_seq + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						//AUIGrid.setGridData(auiGridFirst, result.list);
						alert("저장되었습니다");
						goSearchShip(machine_plant_seq);
					};
				}
			);
		}
		
		//유효성 체크
		function isValid() {
			var data = AUIGrid.getGridData(auiGridRight);
			var disLength = '';
			var numQty = '';
			for(var i in data) {
				var subRows = data[i];
				disLength = AUIGrid.getItemsByValue(auiGridRight, "part_no", subRows.part_no);
				if(subRows.qty == 0 ) {
					alert("수량을 확인해주세요.");
					return;
				}
			}
			return AUIGrid.validateGridData(auiGridRight, ["machine_plant_seq", "part_no", "part_name", "qty", "part_type_bak", "stock_yn", "total_price"], "각 항목에 값을 입력해주세요.");
		}
		
		//부품조회 창 열기
		function goPartList() {
// 			var machineName = $M.getValue("hidMchNm");
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var items = AUIGrid.getAddedRowItems(auiGridRight);
			if(items.length > 0) {
				alert("추가된 행을 저장하고 시도해주세요.");
				return;
			}
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {	
				alert("장비 모델을 선택하고 부품 조회를 진행해주세요.");
				return;	
			}
			openSearchPartPanel('setPartInfo', 'Y');
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
// 			var machineName =  $M.getValue("hidMchNm");
			var machinePlantSeq =  $M.getValue("machine_plant_seq");
			var partNo ='';
			var partName ='';
			var quantity ='';
			var goodType ='';
			var stockYn ='';
			var unitPrice ='';
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					quantity = typeof rowArr[i].qty == "undefined" ? quantity : rowArr[i].qty;
					goodType = typeof rowArr[i].part_type_bak == "undefined" ? goodType : rowArr[i].part_type_bak;
					stockYn = typeof rowArr[i].stock_yn == "undefined" ? stockYn : rowArr[i].stock_yn;
					unitPrice = typeof rowArr[i].cust_price == "undefined" ? unitPrice : rowArr[i].cust_price;
// 					row.machine_name =  machineName;
					row.machine_plant_seq =  machinePlantSeq;
					row.part_no = partNo;
					row.part_name = partName;
					row.qty = quantity;
					row.part_type_bak = goodType;
					row.stock_yn = stockYn;
					row.unit_price = unitPrice;
					row.total_price = '';
					AUIGrid.addRow(auiGridRight, row, 'last');
				}
			}
		}
		
		//행 추가
		function fnAdd() {
// 			var machineName = $M.getValue("hidMchNm");
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {	
				alert("장비 모델을 선택하고 행 추가를 진행해주세요.");
				return;	
			}
			var items = AUIGrid.getAddedRowItems(auiGridRight);
			if(items.length > 0) {
				alert("추가된 행을 저장하고 계속해주세요.");
			} else {
				var row = new Object();
// 				row.machine_name = machineName;
				row.machine_plant_seq = machinePlantSeq;
				row.part_no = '';
				row.part_name = '';
				row.qty = '';
				row.part_type_bak = '';
				row.stock_yn = '';
				row.unit_price = '';
				row.total_price = '';
				AUIGrid.addRow(auiGridRight, row, 'last');
			}
		}
		
		//출하 시 지급품 목록
		var part_type_bak_list = [{"code":"B", "value" : "기본"}, {"code" :"A", "value" :"추가"}, {"code" :"AA", "value" :"추가(어태치)"}, {"code" :"K", "value" :"버킷"}];
		//상세 조회
		function goSearchShip(param) {
			console.log("param : ", param);
			$M.goNextPageAjax(this_page +"/ship/search/" + param, '', '',
				function(result) {
					if(result.success) {
						console.log(result);
						AUIGrid.setGridData(auiGridRight, result.list);
						$("#total_cnt").html(result.total_cnt);
// 						$M.setValue("hidMchNm", param);
						$M.setValue("machine_plant_seq", param);
						var bucketLeng = AUIGrid.getItemsByValue(auiGridRight, "part_type_bak", "K");
						var baseLeng = AUIGrid.getItemsByValue(auiGridRight, "part_type_bak", "B");
						var addLeng = AUIGrid.getItemsByValue(auiGridRight, "part_type_bak", "A");
						var addAttachLeng = AUIGrid.getItemsByValue(auiGridRight, "part_type_bak", "AA");
						console.log("버킷: ", bucketLeng , ",기본 : ", baseLeng);
						AUIGrid.updateRow(auiGridFirst, {
							ba_cnt : baseLeng.length + addLeng.length + addAttachLeng.length, //구성수
							k_cnt : bucketLeng.length //버킷
						}, AUIGrid.getRowIndexesByValue(auiGridFirst, "machine_plant_seq", param));
					}
			});
		}
		
		//그리드 생성
		function createAUIGridFirst() {
			//장비목록
			var gridProsFirst = {
				rowIdField : "_$uid",	
				enableFilter:true,
				rowStyleFunction : function(rowIndex, item) {
					if(item.sale_yn == "N") {
						return "aui-color-red";
					} 
				}
			};
			var columnLayoutFirst = [
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "40%",
					style : "aui-center aui-link",
					editable : true,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "구성수", 
					dataField : "ba_cnt", 
					style : "aui-center",
					width : "30%",
					editable : false,
				},
				{
					headerText : "버켓구성수", 
					dataField : "k_cnt", 
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "sale_yn", 
					dataField : "sale_yn", 
					style : "aui-center",
					editable : false,
				}
			];
			auiGridFirst = AUIGrid.create("#auiGridFirst", columnLayoutFirst, gridProsFirst);
			AUIGrid.setGridData(auiGridFirst, ${list});
			$("#auiGridFirst").resize();
			AUIGrid.bind(auiGridFirst, "cellClick", function(event) {
				console.log("event : ", event);
				var machine_plant_seq =  event.item.machine_plant_seq;
				goSearchShip(machine_plant_seq);
			});
			AUIGrid.hideColumnByDataField(auiGridFirst, "sale_yn");
			AUIGrid.setFilterByValues(auiGridFirst, "sale_yn", "Y");
			
			var stock_yn_list = ["Y", "N"];
			var gridProsRight = {
				rowIdField : "_$uid",	
				editable : true,
				showStateColumn : true,
				showFooter : true,
				footerPosition : "top"
			};
			
			var columnLayoutRight = [
				{
					dataField : "machine_basic_part_seq",
					visible : false
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "장비명", 
					dataField : "machine_name",
					visible : false
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "19%",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "RemoteListRenderer",
						fieldName : "part_no",
						remoter : function( request, response ) { // remoter 지정 필수
							if(String(request.term).length < 2) {
								alert("2글자 이상 입력하십시오.");
								response(false); // 데이터 요청이 없는 경우 반드시 false 삽입하십시오.
								return;
							}
							var stock_mon = '${inputParam.s_current_mon}';
							var param = {
								"stock_mon" : stock_mon,
								"s_sort_key" : "tp.part_no", 
								"s_part_no" : request.term,
								"s_sort_method" : "desc",
								//"s_part_mng_cd" : "1"
							};
							$M.goNextPageAjax("/comp/comp0601" + "/search", $M.toGetParam(param), {method : 'get'},
								function(result) {
									if(result.success) {
										recentPartList = result.list;
										response(result.list); 
									};
								}
							);
						},
						noDataMessage : "데이터가 없습니다",
						listTemplateFunction : function(rowIndex, columnIndex, text, item, dataField, listItem) {
							var html = '';
							html += '<div class="myList-style">';
							html += '	<span class="myList-col" style="width:100px;">' + listItem.part_no + '</span>';
							html += '	<span class="myList-col" style="width:100px;">' + listItem.part_name + '</span>';
							html += '	<span class="myList-col" style="width:100px;">' + listItem.cust_price + '</span>';
							html += '</div>';
							return html;
						}
					}
				},
				{
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left aui-editable",
					width : "25%",
					editable : true,
				},
				{
					headerText : "수량", 
					dataField : "qty", 
					style : "aui-editable",
					dataType : "numeric",
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    allowNegative : true,
					},
					width : "5%",
					editable : true,
				},
				{
					headerText : "기준", 
					dataField : "part_type_bak",
					style : "aui-editable",
					width : "10%",
					renderer : {
						type : "DropDownListRenderer",
						list : part_type_bak_list,
						keyField : "code", 
						valueField : "value" 
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = "";
						for(var i=0,len=part_type_bak_list.length; i<len; i++) {
							if(keyValueList[i]["code"] == value) {
								retStr = keyValueList[i]["value"];
								break;
							}
						}
						return retStr;
					},
					editable : true,
				},
				{
					headerText : "스탁지급", 
					dataField : "stock_yn", 
					style : "aui-editable",
					width : "10%",
					renderer : {
						type : "DropDownListRenderer",
						list : stock_yn_list
					},
					editable : false,
				},
				{
					headerText : "부품마스터적용",
					dataField : "master_price_yn", 
					width : "105", 
					minWidth : "45",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					},
				},
				{
					headerText : "마스터단가", 
					dataField : "refer_price", 
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "단가", 
					dataField : "unit_price", 
					style : "aui-right aui-editable",
					dataType : "numeric",
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true
					},
					styleFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return item.master_price_yn == "Y" ? "cancelPrice" : ""; 
					},
					width : "10%",
					formatString : "#,##0",
					editable : true,
				},
				{
					headerText : "합계", 
					dataField : "total_price", 
					style : "aui-right",
					dataType : "numeric",
					width : "10%",
					formatString : "#,##0",
					editable : true,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						return ( item.qty * item.unit_price ); 
					},
					styleFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return item.master_price_yn == "Y" ? "cancelPrice" : ""; 
					},
				},
				{
					headerText : "삭제", 
					dataField : "delete_btn", 
					renderer : {
						type : "ButtonRenderer",
						labelText : "삭제", 
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								if(AUIGrid.isAddedById(auiGridRight, event.item._$uid)) {
									AUIGrid.removeSoftRows(event.pid, event.rowIndex);
									
								}
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex"); 
							}
						},
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "use_yn",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayoutRight = [ 
				{
					labelText : "합계",
					positionField : "unit_price"
				},
				{
					dataField : "total_price",
					positionField : "total_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayoutRight, gridProsRight);
			AUIGrid.setGridData(auiGridRight, []);
			AUIGrid.setFooter(auiGridRight, footerColumnLayoutRight);
			$("#auiGridRight").resize();
			AUIGrid.bind(auiGridRight, "cellEditBegin", function(event) {
				var rowIdField = AUIGrid.getProp(auiGridRight, "rowIdField");
				if(AUIGrid.isAddedById(auiGridRight, event.item[rowIdField])) {
		            return true;
			    } else if(event.dataField == 'unit_price' || event.dataField == 'qty' || event.dataField == 'part_name') {
			    	return true;
			    }
			    return false; 
			});
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditCancel", auiCellEditHandler);
		}
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
// 			var machineName =  $M.getValue("hidMchNm");
			var machinePlantSeq =  $M.getValue("machine_plant_seq");
			switch(event.type) {
			case "cellEditEnd" :
				if(event.dataField == "part_no") {
					var partItem = getPartItem(event.value);
					if(typeof partItem === "undefined") {
						return;
					}
					// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
					AUIGrid.updateRow(auiGridRight, {
// 						machine_name : machineName,
						machine_plant_seq : machinePlantSeq,
						part_name : partItem.part_name,
						unit_price : partItem.cust_price
					}, event.rowIndex);
				}
				break;
			case "cellEditCancel" :
				if(event.dataField == "part_no") {
					if(typeof event.item.title == "undefined" || event.item.title == "") {
						//AUIGrid.removeRow(auiGrid, event.rowIndex);
					}
				}
				break;
			}
		};
		
		// part_no 으로 검색해온 정보 아이템 반환.
		function getPartItem(part_no) {
			var item;
			$.each(recentPartList, function(n, v) {
				if(v.part_no == part_no) {
					item = v;
					return false;
				}
			});
			return item;
		};
		
		//매출정지장비포함 체크하면 포함되게
		function fnSaleChange() {
			var saleYn = $("input:checkbox[id='sale_stop']").is(":checked"); 
			if(saleYn) {
				AUIGrid.setFilterByValues(auiGridFirst, "sale_yn", ["Y", "N"]);
				total_cnt_first = AUIGrid.getRowCount(auiGridFirst);
				$("#total_cnt_first").html(total_cnt_first);
			} else {
				AUIGrid.setFilterByValues(auiGridFirst, "sale_yn", "Y");
				total_cnt_first = AUIGrid.getRowCount(auiGridFirst);
				$("#total_cnt_first").html(total_cnt_first);
			}
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
		<div class="content-box" style="border: none !important;">
	<!-- 메인 타이틀 -->
	<!-- /메인 타이틀 -->
	<div class="contents">
	<input type="hidden" id="hidMchNm" name="hidMchNm"/>
	<input type="hidden" id="machine_plant_seq" name="machine_plant_seq"/>
			<div class="row">
<!-- 메뉴목록 -->
						<div class="col-3">
							<div class="title-wrap mt10">
								<div class="btn-group">
									<h4>장비목록</h4>
									<div class="right">
									<input type="checkbox" id="sale_stop" onchange="javascript:fnSaleChange();"/><label for="sale_stop">매출정지장비포함</label>
									</div>
								</div>						
							</div>
							<div id="auiGridFirst" style="margin-top: 5px;height: 485px;"></div>
							<div class="btn-group mt5 custheight">		
								<div class="left">
									총 <strong class="text-primary" id="total_cnt_first">0</strong>건 
								</div>				
							</div>
						</div>
						<!-- /메뉴목록 -->						
						<div class="col-9">
							<div class="row">
								<!-- 메뉴정보 -->								
								<div class="col-12" style="margin-top: -5px;">
									<div class="title-wrap mt10">
										<div class="btn-group">
											<h4>출하 시 지급품 목록 </h4>
											<div class="right">
												<span class="text-warning" tooltip>※ &lt;부품마스터 적용&gt; 시 출하지급품 단가를 무시하고, 부품마스터의 단가(전략가있으면 전략가, 없으면 소비자가)를 적용합니다.</span>
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
											</div>
										</div>					
									</div>									
									<!-- 폼테이블 -->	
									<div>
										<div id="auiGridRight" style="margin-top: 5px;height: 485px;"></div>
									</div>
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5 custheight">		
										<div class="left">
											총 <strong class="text-primary" id="total_cnt">0</strong>건 
										</div>				
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
<!-- /메뉴정보 -->									
							</div>

						</div>
					</div>
				</div>
			</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>