<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 바코드출력관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-02-12 14:22:17
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var stockDtMap = "${stockDtMap}";
	var auiGrid;
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		fnInit();
	});
	
	function fnInit() {
		$M.setValue("s_warehouse_cd", "${SecureUser.org_code}");
	}
	
	// 그리드 생성
	function createAUIGrid() {
		var gridPros = {
				rowIdField : "_$uid",
				showRowNumColum : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
				enableFilter :true,
				// 수정 표시
				showStateColumn : true
		};
		
		var columnLayout = [
			{
				dataField : "barcode",
				visible : false
			},
			{
				dataField : "deal_cust_no",
				visible : false
			},
			{
				dataField : "deal_cust_no2",
				visible : false
			},
			{
				dataField : "deal_cust_name2",
				visible : false
			},
			{
				dataField : "part_qr_no",
				visible : false
			},
			{
				headerText : "부품번호",
				dataField : "part_no",
				// width : "13%",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						var param = {
								's_search_kind' : 'DEFAULT_PART',
								's_warehouse_cd' : "${SecureUser.org_code}",
								's_only_warehouse_yn' : "N",
								's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
						};
						return fnGetPartSearchRenderer(dataField, param);
					},
				},
				filter : {
					showIcon : true
				}
			},
			// {
			// 	headerText : "신번호",
			// 	dataField : "part_new_no",
			// 	width : "13%",
			// 	style : "aui-center",
			// 	editable : false,
			// 	labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		    //         return value == "" || value == null ? "-" : value;
			// 	},
			// 	filter : {
			// 		showIcon : true
			// 	}
			// },
			{
				headerText : "부품명",
				dataField : "part_name",
				// width : "25%",
				style : "aui-left",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		            return value == "" || value == null ? "-" : value;
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "매입처",
				dataField : "deal_cust_name",
				width : "11%",
				style : "aui-center  aui-editable",
				editable : true,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "" || value == null ? "-" : value;
				}
			},
			{
				headerText : "입고일자",
				dataField : "stock_dt",
				dataType : "date",
				width : "10%",
				style : "aui-center aui-editable",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				},
				editable : true,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "매수",
				dataField : "output_count",
				width : "7%",
				style : "aui-center  aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		            return value == "" || value == null ? "1" : value;
				},
			},
			{
				headerText : "저장위치",
				dataField : "storage_name",
				width : "15%",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		            return value == "" || value == null ? "-" : value;
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "8%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);		
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
						}
					},
					visibleFunction   :  function(rowIndex, columnIndex, value, item, dataField ) {
						// 삭제버튼은 행 추가시에만 보이게 함
						if(AUIGrid.isAddedById("#auiGrid",item._$uid)) {
						  	return true;
						} else {
						  	return false;
						}	
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			if (event.dataField == "part_no") {
				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					return false;
				}
			}
		});
		
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
		// 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
		AUIGrid.bind(auiGrid, "addRow", function( event ) {
			fnUpdateCnt();
		});
		
		AUIGrid.bind(auiGrid, "removeRow", function( event ) {
			fnUpdateCnt();
		});

		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// 22.04.20 김상덕. 모든직원 마스터로 이동되어 부품마스터로 이동되는 링크 삭제. 이원영파트장님 요청
			// 부품명 셀 클릭 시 부품마스터상세 팝업 호출
		});
		
// 		AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
			
// 		});	
		
		$("#auiGrid").resize();
		
	}
	
	function fnUpdateCnt() {
		var cnt = AUIGrid.getGridData(auiGrid).length;
		$("#total_cnt").html(cnt);
	}
	
	function goSearch() {
		if($M.getValue('s_warehouse_cd') == '') {
			alert('부품창고를 선택해주세요.');
			return;
		}
		if($M.getValue('s_deal_cust_no') == '') {
			alert('매입처를 입력해주세요.');
			return;
		}
		var param = {
			s_warehouse_cd  : $M.getValue("s_warehouse_cd"),
			s_deal_cust_no : $M.getValue("s_deal_cust_no"),
			s_sort_key : "stock_dt",
			s_sort_method : "desc",
			s_sort_key1 : "part_no",
			s_sort_method1 : "asc"
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		// var field = ["s_stock_dt"];
		var field = ["s_deal_cust_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				// goSearch();
				fnSearchClientComm();
			};
		});
	}
	
	// 행추가
	function fnAdd() {
// 		var params = AUIGrid.getGridData(auiGrid);
// 		if (params.length == 0) {
// 			alert("부품창고를 선택하고 행 추가를 진행해주세요.");
// 			return false;
// 		}

		var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
		fnSetCellFocus(auiGrid, colIndex, "part_no");
		var item = new Object();
// 		if(fnCheckGridEmpty(auiGrid)) {
	    		item.part_no = "",
	    		item.part_name = "",
	    		item.stock_dt = "-",
	    		item.deal_cust_name = "-",
	    		item.deal_cust_no = "",
	    		item.output_count = "1",
	    		item.storage_name = "",
	    		item.barcode = "",
	    		AUIGrid.addRow(auiGrid, item, 'last');
// 		}	
	}
	
	// 편집 핸들러
	function auiCellEditHandler(event) {
		console.log("event", event);
		switch(event.type) {
		case "cellEditEndBefore" :
			if(event.dataField == "part_no") {
				var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);	
				if (isUnique == false && event.value != "" && event.value != event.item.part_no) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
					}, 1);
					return "";
				} else {
					if (event.value == "") {
						return event.oldValue;							
					}
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
					console.log("item : ", item);
					if(item === undefined) {
						AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGrid, {
							part_name : item.part_name,
							part_unit : item.part_unit,
							barcode : item.barcode
						}, event.rowIndex);
					}
			    }
				if(event.dataField == "deal_cust_name") {
					$M.setValue("c_row_no", event.rowIndex);
					var param = {
						's_cust_name' : event.value
					};
					AUIGrid.updateRow(auiGrid, {deal_cust_no : "", deal_cust_name : ""}, event.rowIndex);
					openSearchClientPanel('setSearchClientInfoRow', 'comm', $M.toGetParam(param));
				}
				break;
			} 
		};
	
	// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
	function fnGetPartItem(part_no) {
		console.log("part_no : ", part_no);
		var item;
		$.each(recentPartList, function(index, row) {
			if(row.part_no == part_no) {
				item = row;
				return false; // 중지
			}
		});
		console.log("fnGetPartItem : ", item);
		return item;
	 };

	//부품조회 창 열기
	function goPartList() {
		var params = AUIGrid.getGridData(auiGrid);
		var items = AUIGrid.getAddedRowItems(auiGrid);

// 		if (params.length == 0) {
// 			alert("부품창고를 선택하고 행 추가를 진행해주세요.");
// 			return false;
// 		}
		
// 		for (var i = 0; i < items.length; i++) {
// 			if (items[i].part_no == "") {
// 				alert("추가된 행을 입력하고 시도해주세요.");
// 				return;
// 			}
// 		}
		openSearchPartPanel('setPartInfo', 'Y');
	}
	 
	// 부품조회 창에서 받아온 값
	function setPartInfo(rowArr) {
		var params = AUIGrid.getGridData(auiGrid);
		// 부품조회 창에서 받아온 값 중복체크
		for (var i = 0; i < rowArr.length; i++ ) {
			var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
			 if (rowItems.length != 0){
// 				 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
				 return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";					 
			 }
		}
		
		var partNo ='';
		var partNewNo ='';
		var partName ='';
		var partUnit ='';
		var outputCount ='';
		var storageName ='';
		var barcode ='';
		var row = new Object();
		if(rowArr != null) {
			for(i=0; i<rowArr.length; i++) {
				partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
				partNewNo = typeof rowArr[i].part_new_no == "undefined" ? partNewNo : rowArr[i].part_new_no;
				partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
				partUnit = typeof rowArr[i].part_unit == "undefined" ? partUnit : rowArr[i].part_unit;
				storageName = typeof rowArr[i].storage_name == "undefined" ? storageName : rowArr[i].storage_name;
				barcode = typeof rowArr[i].barcode == "undefined" ? barcode : rowArr[i].barcode;
				row.part_no = partNo;
				row.part_new_no = partNewNo;
				row.part_name = partName;
				row.part_unit = partUnit;
				row.storage_name = storageName;
				row.barcode = barcode;
				row.output_count = '1';
				row.stock_dt = '-';
				AUIGrid.addRow(auiGrid, row, 'last');
			}
		}
	}
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["part_no", "part_name"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 엑셀다운로드
	function fnDownloadExcel() {
		  fnExportExcel(auiGrid, "부품코드출력");
	}
	
	// 창고별 입고일 세팅
	// function goStockDtListChange() {
	// 	// 선택된 창고코드
	// 	var warehouseCd = $M.getValue("s_warehouse_cd");
	// 	// select box 옵션 전체 삭제
	// 	$("#s_stock_dt option").remove();
	// 	// select box option 추가
	// 	$("#s_stock_dt").append(new Option('- 선택 -', ""));
	//
	// 	// 해당창고에 입고일 데이터가 있을때
	// 	if(stockDtMap.hasOwnProperty(warehouseCd)) {
	// 		var stockDtList = stockDtMap[warehouseCd];
	// 		for(item in stockDtList) {
	// 			// 입고일 목록에 해당 창고의 최근 6개월의 입고일 option 추가
	// 			$("#s_stock_dt").append(new Option(stockDtList[item].code_name, stockDtList[item].code_value));
	// 		}
	// 	} 
	// }

	function fnGetPageData() {
		// 그리드에 체크된 값 가져오기
		var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
		var newRows = [];
		// 매수만큼 데이터 반복
		for (var i in rows) {
			var duplRows = [];
			for (var j = 0; j < rows[i].output_count; j++) {
				newRows.push(rows[i]);
			}
		}
		return newRows;
	}
	
	// QR코드 저장
	function goQrSave() {
		var frm = $M.toValueForm(document.main_form);
		var gridForm = fnCheckedGridDataToForm(auiGrid);
		$M.copyForm(gridForm, frm);

		$M.goNextPageAjax(this_page + "/qrSave", gridForm, {method: "POST"},
				function (result) {
					if (result.success) {
						var partQrJson = JSON.parse(result.partQrCodeMap);
						var checkGridData = AUIGrid.getCheckedRowItems(auiGrid);
						for(var i = 0; i < checkGridData.length; i++) {
							AUIGrid.updateRow(auiGrid, { "part_qr_no" : partQrJson[checkGridData[i].item['part_no']] }, checkGridData[i].rowIndex);
						}
					}
				}
		);
	}
	
	// 매입처조회
	function fnSearchClientComm() {
		var param = {
			's_cust_name' : $M.getValue('s_deal_cust_name')
		};
		openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
	}
	
	// 매입처 조회 팝업 클릭 후 리턴
	function setSearchClientInfo(data) {
		$M.setValue("s_deal_cust_name", data.cust_name);
		$M.setValue("s_deal_cust_no", data.cust_no);
	}
	
	function goApplyInfo() {
		var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
		if (items.length == 0) {
			alert("체크된 데이터가 없습니다.");
			return false
		}
		var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
		var param = {
			stock_dt : $M.getValue("temp_stock_dt"),
		}
		for(var i in checkedItems){
			AUIGrid.updateRow(auiGrid, param, checkedItems[i].rowIndex);
		}
	}
	function setSearchClientInfoRow(data) {
		$M.setValue("c_deal_cust_name", data.cust_name);
		$M.setValue("c_deal_cust_no", data.cust_no);
		var changeRow = $M.getValue("c_row_no");
		var param = {
			deal_cust_no : data.cust_no,
			deal_cust_name : data.cust_name,
		}
		AUIGrid.updateRow(auiGrid, param, changeRow);
		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			if(gridData[i].deal_cust_no2 == data.cust_no){
				AUIGrid.updateRow(auiGrid, param, i);
			}
		}
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<input type="hidden" name="c_row_no" id="c_row_no">
	<input type="hidden" name="c_deal_cust_no" id="c_deal_cust_no">
	<input type="hidden" name="c_deal_cust_name" id="c_deal_cust_name">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<div class="contents">

<!-- 메인 타이틀 -->
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="60px">
								<col width="130px">
								<col width="130px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th >부품창고</th>
									<td>
										<input type="text" style="width : 140px"; 
											id="s_warehouse_cd" 
											name="s_warehouse_cd" 
											idfield="code_value"
											easyui="combogrid"
											header="Y"
											easyuiname="centerList" 
											panelwidth="250"
											maxheight="155"
											enter="goSearch()"
											textfield="code_name"
											multi="N"
<%--											change="goStockDtListChange()"--%>
											/>
									</td>
<%--									<th>입고일</th>--%>
<%--									<td>--%>
<%--										<select id="s_stock_dt" name="s_stock_dt" class="form-control">--%>
<%--										</select>--%>
<%--									</td>		--%>
									<th>매입처</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0" id="s_deal_cust_name" name="s_deal_cust_name">
											<input type="hidden" id="s_deal_cust_no" name="s_deal_cust_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
										</div>
									</td>	
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
									<td class="text-right">
										<span class="text-warning">※ 매입처 변경 시 변경한 매입처가 매입처2인 모든 부품이 일괄 변경됩니다.</span>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt5">
						<h4>부품조회내역</h4>
						<div class="title-wrap mt5">
							<div class="right dpf">
								<div class="input-group mr5" style="width: 100px;">
									<input type="text" class="form-control border-right-0  calDate" id="temp_stock_dt" name="temp_stock_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
								</div>
							</div>
						<div class="btn-group">
							<div class="right">
								<div>
									
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>
						</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 480px;" ></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
	</div>
<!-- /contents 전체 영역 -->		
</form>
</body>
</html>