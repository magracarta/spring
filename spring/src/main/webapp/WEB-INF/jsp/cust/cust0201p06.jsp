<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > 부품대량입력
-- 작성자 : 박예진
-- 최초 작성일 : 2021-05-11 01:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGrid;
		var confirmYn = "${inputParam.confirm_yn}";
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridProps = {
				noDataMessage : "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
				rowIdField : "_$uid",
				editable : true, // 수정 모드
				editableOnFixedCell : true,
				selectionMode : "multipleCells", // 다중셀 선택
				showStateColumn : true,
				showEditedCellMarker : false,
				softRemovePolicy :"exceptNew",
				wrapSelectionMove : true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				enableFilter : false,
				softRemoveRowMode : false,
				// 체크박스 출력 여부
// 				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
// 				showRowAllCheckBox : true,
				showAutoNoDataMessage : true,
			};
	
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					style : "aui-center aui-editable",
					width : "55%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "수량", 
					dataField : "qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "15%", 
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
						      onlyNumeric : true,
					      validator : AUIGrid.commonValidator
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "검증 결과",
					dataField : "result_msg",
					style : "aui-center",
					width : "30%",
					editable : false,
					filter : {
						showIcon : true
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var msg = "";
						switch(value) {
							case "Y" : msg = "정상"; 
									break;
							case "N" : msg = "부품번호 오류"; 
									break;
							case "Q" : msg = "수량 오류"; 
									break;
							case "R" : msg = "재검증 필요"; 
									break;
						}
						return msg;
					}
				},
// 				{
// 					dataField : "check_yn",
// 					visible : false,
// 				},
				{
					dataField : "verify_yn",
					visible : false,
				},
				{
					dataField : "part_mng_cd",
					visible : false,
				},
			];
	
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridProps);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid,  "pasteEnd", function(event) {
				fnAddPart();
			});

			AUIGrid.bind(auiGrid,  "cellEditEnd", function(event) {
				// 새로 입력한 값이 기존 값과 같지 않으면 검증 N으로 업데이트
				if(event.oldValue != "" && event.value != event.oldValue) {
					AUIGrid.updateRow(auiGrid, {"verify_yn" : "N"}, event.rowIndex);
					AUIGrid.updateRow(auiGrid, {"result_msg" : "R"}, event.rowIndex);
				}
			});

			// cellEditEndBefore 이벤트 바인딩
			AUIGrid.bind(auiGrid,  "cellEditEndBefore", function(event) {
				// 검증 결과 컬럼엔 복사 안되도록 추가
				if(event.columnIndex == 2) {
					return null;
				} 
				if(event.isClipboard) {
					return event.value;
				}
				return event.value; // 원래값
			});

			// 체크박스 클린 이벤트 바인딩
// 			AUIGrid.bind(auiGrid, "rowCheckClick", function(event) {
// 				// 체크 시 체크 여부 update
// 				if(event.checked == true) {
// 					AUIGrid.updateRow(auiGrid, {"check_yn" : "Y"}, event.rowIndex);
// 				} else {
// 					AUIGrid.updateRow(auiGrid, {"check_yn" : "N"}, event.rowIndex);
// 				}
// 				return true;
// 			});
			
			// 전체 체크박스 클릭 이벤트 바인딩
// 			AUIGrid.bind(auiGrid, "rowAllChkClick", function(event) {
// 				// 체크 시 체크 여부 update
// 				if(event.checked == true) {
// 					var items = AUIGrid.getCheckedRowItems(auiGrid);
// 					for (var i = 0; i < items.length; i++) {
// 						AUIGrid.updateRow(auiGrid, {"check_yn" : "Y"}, items[i].rowIndex);
// 					}
// 				} else {
// 					var gridData = AUIGrid.getGridData(auiGrid);
// 					for (var i = 0; i < gridData.length; i++) {
// 						AUIGrid.updateRow(auiGrid, {"check_yn" : "N"}, i);
// 					}
// 				}
// 				return true;
// 			});
			
			$("#auiGrid").resize();
		}
		
		// 부품검증
		function fnConfirm() {
			// 체크한 그리드 데이터
// 			var gridData = AUIGrid.getCheckedRowItems(auiGrid);
// 			if(gridData.length == 0) {
// 				alert("체크한 데이터가 없습니다.");
// 				return;
// 			}
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("검증할 데이터가 없습니다.");
				return;
			}
			
			// 부품번호, 수량 필수 입력 체크
// 			for(var i = 0; i < gridData.length; i++) {
// 				rowIndex = gridData[i].rowIndex;
// 				if(gridData[i].item.part_no == "") {
// 					return AUIGrid.showToastMessage(auiGrid, rowIndex, 0, "부품번호는 필수 입력입니다.");
// 				}
// 				if(gridData[i].item.qty == "") {
// 					return AUIGrid.showToastMessage(auiGrid, rowIndex, 1, "수량은 필수 입력입니다.");
// 				}
// 			}

			var frm = $M.toValueForm(document.main_form);
			
			var option = {
				isEmpty : true
			};

// 			var partNoArr = [];
			var allPartNoArr = [];
			var allQtyArr = [];
			var allCheckYnArr = [];
			
			// 체크한 부품번호
// 			for(var i = 0; i < gridData.length; i++) {
// 				partNoArr.push(gridData[i].part_no.toUpperCase());
// 			}

			// 전체 그리드 데이터 (체크 여부 상관없음)
			var allGridData = AUIGrid.getGridData(auiGrid);
			
			for(var i = 0; i < allGridData.length; i++) {
				allPartNoArr.push(allGridData[i].part_no.toUpperCase());
				allQtyArr.push(allGridData[i].qty);
				allCheckYnArr.push(allGridData[i].check_yn);
			}
			
			var param = {
// 					"part_no_str" : $M.getArrStr(partNoArr, option),
					"all_part_no_str" : $M.getArrStr(allPartNoArr, option),
					"all_qty_str" : $M.getArrStr(allQtyArr, option),
					"all_check_yn_str" : $M.getArrStr(allCheckYnArr, option)
			}
			
			$M.goNextPageAjax(this_page + "/partVerify", $M.toGetParam(param), {method : 'post' },
				function(result) {
					if(result.success) {
						alert("검증이 완료되었습니다.");
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);	

						// 체크되어있던 데이터 다시 체크
// 						AUIGrid.addCheckedRowsByValue(auiGrid, "check_yn", "Y");
					}
				}
			);
		}
	
		// 적용
		function goApply() {
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("적용할 데이터가 없습니다.");
				return;
			}
			
			// 검증되지 않은 부품 있을 시 적용 불가 체크
			for(var i = 0; i < gridData.length; i++) {
				// 23.02.28 정윤수 부품발주 부품추가 시 정상재고 아닌 경우 확인창 띄움
				if(confirmYn == "Y" && gridData[i].part_mng_cd != "1"){
					if(confirm("정상재고가 아닌 부품이 선택되었습니다. ("+gridData[i].part_no+")\n계속 진행 하시겠습니까?") == false){
						return false;
					}
				}
				confirmYn = "N"; // 정상재고가 아닌 부품이 여러개인 경우 한번만 확인
				if(gridData[i].verify_yn == "") {
					alert("검증되지 않은 부품이 있습니다. 다시 검증해주십시오.");
					return false;
				}	
			}

			// 부품번호, 수량 필수 입력 체크
// 			for(var i = 0; i < gridData.length; i++) {
// 				rowIndex = gridData[i].rowIndex;
// 				if(gridData[i].item.part_no == "") {
// 					return AUIGrid.showToastMessage(auiGrid, rowIndex, 0, "부품번호는 필수 입력입니다.");
// 				}
// 				if(gridData[i].item.qty == "") {
// 					return AUIGrid.showToastMessage(auiGrid, rowIndex, 1, "수량은 필수 입력입니다.");
// 				}
// 			}

			var frm = $M.toValueForm(document.main_form);
			
			var option = {
				isEmpty : true 
			};

			var partNoArr = [];
			var qtyArr = [];
			
			// 정상인 부품번호와 수량만 세팅
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].result_msg == "Y") {
					partNoArr.push(gridData[i].part_no.toUpperCase());
					qtyArr.push(gridData[i].qty);
				}
			}
			
			if(partNoArr.length == 0){
				alert("적용할 수 있는 품번이 없습니다.");
				return;
			}

			$M.setValue(frm, "part_no_str", $M.getArrStr(partNoArr, option));
			$M.setValue(frm, "qty_str", $M.getArrStr(qtyArr, option));

			var msg = "검증결과가 정상인 것만 추가됩니다.";
			
			$M.goNextPageAjaxMsg(msg, this_page + "/searchInputPart", frm, {method : 'get'},
				function(result) {
					if(result.success) {
						try{
							opener.${inputParam.parent_js_name}(result.list);
							window.close();	
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
					}
				}
			);
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["part_no", "qty"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}

		// 행추가 
		function fnAddPart() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");
			var item = new Object();
    		item.part_no = "",
    		item.qty = "",
    		item.result_msg = "",
    		item.check_yn = "N",
    		item.verify_yn = "N",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
// 		// 그리드 초기화
// 		function fnClear() {
// 			AUIGrid.clearGridData(auiGrid);
// 		}

// 		// 선택한 로우 삭제
// 		function fnCheckClear() {
// 			// 상단 그리드의 체크된 행들 얻기
// 			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
// 			if(rows.length <= 0) {
// 				alert('삭제할 데이터가 없습니다.');
// 				return;
// 			};
// 			// 선택한 상단 그리드 행들 삭제
// 			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
// 			AUIGrid.removeCheckedRows(auiGrid);
// 		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="cust_no" id="cust_no" value="${inputParam.cust_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	

            <div class="title-wrap">
					<h4>부품대량입력</h4>
					<div class="right">
						<div class="text-warning ml5">
							※엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.
						</div>
<!-- 						<button type="button" class="btn btn-default" onclick="javascript:fnCheckClear();">체크 후 삭제</button> -->
<!-- 						<button type="button" class="btn btn-default" onclick="javascript:fnClear();">그리드 초기화</button> -->
					</div>
            </div>
				<div id="auiGrid" style="margin-top: 5px; height: 650px;"></div>

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
</form>
</body>
</html>