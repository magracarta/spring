<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품호환성관리 > null > 호환성 파일 업로드
-- 작성자 : 박예진
-- 최초 작성일 : 2021-07-13 11:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGrid;
		
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
				showEditedCellMarker : false,
				selectionMode : "multipleCells", // 다중셀 선택
				showStateColumn : false,
				softRemovePolicy :"exceptNew",
				wrapSelectionMove : true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				enableFilter : true,
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
					style : "aui-center",
					width : "25%",
					editable : true,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-center",
					width : "35%",
					editable : true,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "수량", 
					dataField : "qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%", 
					style : "aui-center",
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
					dataField : "check_result",
					style : "aui-center",
					width : "30%",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					dataField : "apply_target_yn",
					visible : false,
				},
				{
					dataField : "verify_yn",
					visible : false,
				},
			];
	
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridProps);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid,  "pasteEnd", function(event) {
				fnAddPart();
			});

// 			AUIGrid.bind(auiGrid,  "cellEditEnd", function(event) {
// // 				if (event.dataField == "part_no" || event.dataField == "part_name" || event.dataField == "qty") {
// 					console.log(event);
// 					console.log(event.oldValue);
					
// 					return event.oldValue;
// // 				}
// 			});

			// cellEditEndBefore 이벤트 바인딩
			AUIGrid.bind(auiGrid,  "cellEditEndBefore", function(event) {
				// 검증 결과 컬럼엔 복사 안되도록 추가
				if(event.columnIndex == 3) {
					return null;
				} 
				if(event.isClipboard) {
					return event.value;
				}
				return event.oldValue; // 원래값
			});

			$("#auiGrid").resize();
		}
		
		// 부품검증
		function fnConfirm() {
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("검증할 데이터가 없습니다.");
				return;
			}

			var frm = document.main_form;
			
			var option = {
				isEmpty : true
			};

			var allPartNoArr = [];
			var allPartNameArr = [];
			var allQtyArr = [];
			
			// 전체 그리드 데이터 (체크 여부 상관없음)
			var allGridData = AUIGrid.getGridData(auiGrid);
			
			for(var i = 0; i < allGridData.length; i++) {
				allPartNoArr.push(allGridData[i].part_no.toUpperCase());
				allPartNameArr.push(allGridData[i].part_name.toUpperCase());
				allQtyArr.push(allGridData[i].qty);
			}
			
// 			var param = {
// 					"all_part_no_str" : $M.getArrStr(allPartNoArr, option),
// 					"all_part_name_str" : $M.getArrStr(allPartNameArr, option),
// 					"all_qty_str" : $M.getArrStr(allQtyArr, option),
// 			}

			$M.setValue("all_part_no_str", $M.getArrStr(allPartNoArr, option));
			$M.setValue("all_part_name_str", $M.getArrStr(allPartNameArr, option));
			$M.setValue("all_qty_str", $M.getArrStr(allQtyArr, option));
			
			$M.goNextPageAjax(this_page + "/partVerify", frm, {method : 'post' },
				function(result) {
					if(result.success) {
						console.log(result.list);
						alert("검증이 완료되었습니다.");
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);	
					}
				}
			);
		}
	
		// 반영
		function goApply() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			}
			
			if($M.getValue("part_ver").trim() == "") {
				alert("버전명은 필수 입력입니다.");
				return false;
			}
			
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("반영할 데이터가 없습니다.");
				return;
			}
			
			// 검증되지 않은 부품 있을 시 적용 불가 체크
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].verify_yn == "") {
					alert("검증되지 않은 부품이 있습니다. 다시 검증해주십시오.");
					return false;
				}	
			}

			var frm = $M.toValueForm(document.main_form);
			
			var option = {
				isEmpty : true 
			};

			var partNoArr = [];
			var partNameArr = [];
			var qtyArr = [];
			var checkResultArr = [];
			var applyTargetYnArr = [];
			
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].part_no != "") {
					partNoArr.push(gridData[i].part_no.toUpperCase());
					partNameArr.push(gridData[i].part_name.toUpperCase());
					qtyArr.push(gridData[i].qty);
					checkResultArr.push(gridData[i].check_result);
					applyTargetYnArr.push(gridData[i].apply_target_yn);
				}
			}
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(partNoArr, option));
			$M.setValue(frm, "part_name_str", $M.getArrStr(partNameArr, option));
			$M.setValue(frm, "qty_str", $M.getArrStr(qtyArr, option));
			$M.setValue(frm, "check_result_str", $M.getArrStr(checkResultArr, option));
			$M.setValue(frm, "apply_target_yn_str", $M.getArrStr(applyTargetYnArr, option));

			var msg = "정상인 부품만 반영됩니다.\n반영하시겠습니까?";
			
			$M.goNextPageAjaxMsg(msg, this_page + "/savePartCommUp", frm, {method : 'post'},
				function(result) {
					if(result.success) {
						try{
							opener.${inputParam.parent_js_name}(result);
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
			return AUIGrid.validateGridData(auiGrid, ["part_no", "part_name", "qty"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}

		// 행추가 
		function fnAddPart() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");
			var item = new Object();
    		item.part_no = "",
    		item.part_name = "",
    		item.qty = "",
    		item.check_result = "",
    		item.verify_yn = "N",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="machine_plant_seq" id="machine_plant_seq" value="${inputParam.machine_plant_seq}">
<input type="hidden" name="upload_dt" value="${inputParam.s_current_dt}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
            <div class="title-wrap">
					<h4>호환성 파일 업로드</h4>
					<div class="right">
						<div class="text-warning ml5">
							※엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.
						</div>
					</div>
            </div>
            <div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">모델명</th>
									<td colspan="3">
										<input type="text" class="form-control width180px" id="machine_name" name="machine_name" readonly="readonly" value="${inputParam.machine_name}">
									</td> 
									<th class="text-right essential-item">버전명</th>
									<td colspan="3">
										<input type="text" class="form-control width180px" id="part_ver" name="part_ver" required="required">
									</td>
								</tr>
							</tbody>
						</table>
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