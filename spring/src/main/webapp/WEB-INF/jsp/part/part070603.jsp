<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 출하시 지급품 관리 > RSP관리 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-03-08 15:38:15
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGridLeft(); // 장비목록 그리드
			createAUIGridRight(); // RSP관리 그리드
			var total_cnt_left = AUIGrid.getRowCount(auiGridLeft);
			$("#total_cnt_left").html(total_cnt_left);
		});

		// 장비의 RSP목록 조회
		function goSearch(value) {
			// 모델전체 조회 시, RSP목록 수량 숨김처리
			if (value == '_ALL_') {
				AUIGrid.hideColumnByDataField(auiGridRight, "rsp_qty");
			} else {
				AUIGrid.showColumnByDataField(auiGridRight, "rsp_qty");
			}

			$M.goNextPageAjax(this_page + "/search/" + value, "",  "",
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGridRight, result.list);
							
							var total_cnt = AUIGrid.getRowCount(auiGridRight);
							$("#total_cnt").html(total_cnt);
						};
					}
				);
		}

		function goSave() {
			var msg = "저장하시겠습니까?"
			if (fnChangeGridDataCnt(auiGridRight) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			// var editedRowItems = AUIGrid.getEditedRowItems(auiGridRight);
			// for(var i=0; i<editedRowItems.length; i++) {
			// 	if(editedRowItems[i].rsp_qty <= 0) {
			// 		alert("수량은 0보다 커야합니다.");
			// 		return;
			// 	}
			// }
			var removeItems = AUIGrid.getRemovedItems(auiGridRight);
			if($M.getValue("machine_plant_seq") == "" && removeItems.length > 0) {
				msg = "모델전체의 RSP목록 조회 후 부품 삭제 시 해당 부품이\n적용된 모델전체에서 삭제됩니다. 저장하시겠습니까?"
			}
			var gridFrm = fnChangeGridDataToForm(auiGridRight, true);
			$M.goNextPageAjaxMsg(msg, this_page + "/save", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("저장이 완료되었습니다.");
							var machinePlantSeq = $M.getValue("machine_plant_seq") == "" ? "_ALL_" : $M.getValue("machine_plant_seq");
							goSearch(machinePlantSeq);
						}
					}
			);

		}
		// 부품대량입력
		function fnMassInputPart() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {
				alert("모델을 선택하고 부품대량입력을 진행해주세요.");
				return;
			}
			var popupOption = "";
			var param = {
				"parent_js_name" : "fnSetInputPart",
			};

			$M.goNextPage('/cust/cust0201p06', $M.toGetParam(param), {popupStatus : popupOption});

		}
		// 부품대량입력 데이터 세팅
		function fnSetInputPart(list) {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var partNo = "";
			var partName = "";
			var partSafeStock2 = 0;
			var row = new Object();
			if (list != null) {
					for (i = 0; i < list.length; i++) {
						var rowItems = AUIGrid.getItemsByValue(auiGridRight, "part_no", list[i].part_no);
						if(rowItems.length == 0) {
						partNo = typeof list[i].part_no == "undefined" ? partNo : list[i].part_no;
						partName = typeof list[i].part_name == "undefined" ? partName : list[i].part_name;
						partSafeStock2 = typeof list[i].part_safe_stock2 == "undefined" ? partSafeStock2 : list[i].part_safe_stock2;
						row.part_rsp_mch_seq = 0;
						row.machine_plant_seq = machinePlantSeq;
						row.part_no = partNo;
						row.part_name = partName;
						row.part_safe_stock2 = partSafeStock2;
						row.rsp_qty = list[i].qty;
						AUIGrid.addRow(auiGridRight, row, 'last');
					}
				}
			}
		}
		//부품조회 창 열기
		function goPartList() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {
				alert("모델을 선택하고 부품조회를 진행해주세요.");
				return;	
			}
			openSearchPartPanel('setPartInfo', 'Y');
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
			var machinePlantSeq =  $M.getValue("machine_plant_seq");
			var partNo ='';
			var partName ='';
			var part_safe_stock2 = 0;
			var row = new Object();
			if(rowArr != null) {
				var partNoArr = AUIGrid.getColumnValues(auiGridRight, "part_no");
				for(i=0; i<rowArr.length; i++) {
					if(partNoArr.indexOf(rowArr[i].part_no) != -1){
						return "부품번호를 다시 확인하세요.\n" + rowArr[i].part_no + " 이미 입력한 부품번호입니다.";
					}
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					part_safe_stock2 = typeof rowArr[i].part_safe_stock2 == "undefined" ? part_safe_stock2 : rowArr[i].part_safe_stock2;
					row.part_rsp_mch_seq = 0;
					row.machine_plant_seq =  machinePlantSeq;
					row.part_no = partNo;
					row.part_name = partName;
					row.part_safe_stock2 = part_safe_stock2;
					row.rsp_qty = 0;
					AUIGrid.addRow(auiGridRight, row, 'last');
				}
			}
		}
		
		//행 추가
		function fnAdd() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {
				alert("모델을 선택하고 행 추가를 진행해주세요.");
				return;
			}
				var row = new Object();
				row.part_rsp_mch_seq = 0;
				row.machine_plant_seq = machinePlantSeq;
				row.part_no = '';
				row.part_name = '';
				row.rsp_qty = '';
				row.use_yn = "Y";
				AUIGrid.addRow(auiGridRight, row, 'last');
		}
		

		//그리드 생성
		function createAUIGridLeft() {
			//장비목록
			var gridProsFirst = {
				rowIdField : "_$uid",
				enableFilter:true,
				showFooter : true,
				footerPosition : "top",
				rowStyleFunction : function(rowIndex, item) {
					if(item.sale_yn == "N") {
						return "aui-color-red";
					}
				}
			};
			var columnLayoutFirst = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					style : "aui-center",
					width : "30%",
					editable : false,
					filter : {
						showIcon : true
					}
				},
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
				},
				{
					headerText : "장비판매수량",
					dataField : "sale_cnt",
					style : "aui-center",
					editable : false,
				},
			];
			// 푸터레이아웃
			var footerColumnLayoutLeft = [
				{
					labelText : "모델전체",
					positionField : "maker_name",
					colSpan : 3,
					style : "aui-center aui-popup",
				},
				{
					dataField : "sale_cnt",
					positionField : "sale_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-center aui-footer",
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayoutFirst, gridProsFirst);
			AUIGrid.setGridData(auiGridLeft, ${list});
			AUIGrid.setFooter(auiGridLeft, footerColumnLayoutLeft); // 푸터
			$("#auiGridLeft").resize();
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				if(event.dataField == "machine_name"){
					// 개별 RSP조회 시 수량 수정가능, 조정 수정불가능
					AUIGrid.setColumnPropByDataField(auiGridRight, "rsp_qty", {style : "aui-center aui-editable"});
					AUIGrid.setColumnPropByDataField(auiGridRight, "part_safe_stock2", {style : "aui-center"});
					var machine_plant_seq =  event.item.machine_plant_seq;
					$M.setValue("machine_plant_seq", machine_plant_seq);
					goSearch(machine_plant_seq);
				}
			});

			// 푸터 클릭 bind
			AUIGrid.bind(auiGridLeft, "footerClick", function(event) {
				if(event.footerValue == "모델전체"){
					// 전체 RSP조회 시 수량 수정불가능, 조정 수정가능
					AUIGrid.setColumnPropByDataField(auiGridRight, "rsp_qty", {style : "aui-center"});
					AUIGrid.setColumnPropByDataField(auiGridRight, "part_safe_stock2", {style : "aui-center aui-editable"});
					$M.setValue("machine_plant_seq", "");
					var param = "_ALL_";
					goSearch(param);
				}
			});
			AUIGrid.hideColumnByDataField(auiGridLeft, "sale_yn");
			AUIGrid.setFilterByValues(auiGridLeft, "sale_yn", "Y");

		}

		function createAUIGridRight(){
			// RSP관리 그리드
			var gridProsRight = {
				rowIdField : "_$uid",
				editable : true,
				showStateColumn : true,
			};

			var columnLayoutRight = [
				{
					dataField : "part_rsp_mch_seq",
					visible : false,
				},
				{
					dataField : "machine_plant_seq",
					visible : false,
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "15%",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								's_search_kind' : 'DEFAULT_PART',
								's_warehouse_cd' : "${SecureUser.org_code}",
								's_only_warehouse_yn' : "N",
								's_not_sale_yn' : "Y",		// 매출정지 제외
								's_not_in_yn' : "Y",			// 미수입 제외
								's_part_mng_cd_str' : "1#6#8"
							};
							return fnGetPartSearchRenderer(dataField, param, "#auiGridRight");
						},
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-center",
					width : "35%",
					editable : false,
				},
				{
					headerText : "적용모델 수",
					dataField : "model_cnt",
					style : "aui-center",
					width : "10%",
					editable : false,
				},
				{
					headerText : "수량",
					dataField : "rsp_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center aui-editable",
					width : "10%",
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
						autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
						allowPoint : false // 소수점(.) 입력 가능 설정
					},
				},
				{
					headerText : "전체 적용부품 수",
					dataField : "part_qty",
					style : "aui-center",
					width : "10%",
					editable : false,
				},
				{
					headerText : "조정",
					dataField : "part_safe_stock2",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center aui-editable",
					width : "10%",
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
						autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
						allowPoint : false // 소수점(.) 입력 가능 설정
					},
				},
				{
					headerText : "삭제",
					dataField : "delete_btn",
					width : "10%",
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

			auiGridRight = AUIGrid.create("#auiGridRight", columnLayoutRight, gridProsRight);
			AUIGrid.setGridData(auiGridRight, []);
			$("#auiGridRight").resize();
			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditBegin", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditEnd", auiCellEditHandler);
		}

		function auiCellEditHandler(event) {
			switch(event.type) {
				case "cellEditBegin" :
					var rowIdField = AUIGrid.getProp(auiGridRight, "rowIdField");
					if(AUIGrid.isAddedById(auiGridRight, event.item[rowIdField]) && event.dataField != 'part_safe_stock2') {
						return true;
					} else if($M.getValue("machine_plant_seq") != "" && event.dataField == 'rsp_qty') {
						return true;
					} else if($M.getValue("machine_plant_seq") == "" && event.dataField == 'part_safe_stock2') {
						return true;
					}
					return false;
					break;
				case "cellEditEndBefore" :
					if(event.dataField == "part_no") {
						var isUnique = AUIGrid.isUniqueValue(auiGridRight, event.dataField, event.value);
						if (isUnique == false && event.value != "" && event.value != event.item.part_no) {
							setTimeout(function() {
								AUIGrid.showToastMessage(auiGridRight, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
							}, 1);
							return event.oldValue;
						} else {
							if (event.value == "") {
								return event.oldValue;
							}
						}
					}
					break;
				case "cellEditEnd" :
					if(event.dataField == "part_no") {
						// remote renderer 에서 선택한 값
						var item = fnGetPartItem(event.value);
						if(item === undefined) {
							AUIGrid.updateRow(auiGridRight, {part_no : event.oldValue}, event.rowIndex);
						} else {
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
							AUIGrid.updateRow(auiGridRight, {
								part_name : item.part_name,
								rsp_qty : 0,
								part_safe_stock2 : item.part_safe_stock2,
							}, event.rowIndex);
						}
					}
					break;
			}
		};

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
		
		function goMbo() {
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
			var param = {
			};

			$M.goNextPage('/sale/sale0408', $M.toGetParam(param), {popupStatus : popupOption});
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
	<input type="hidden" id="machine_plant_seq" name="machine_plant_seq"/>
			<div class="row">
<!-- 메뉴목록 -->
				<div class="col-3" style="margin-top: -5px;">
					<div class="title-wrap mt10">
						<div class="btn-group">
							<h4>장비목록</h4>
							<div class="right">
								<button type="button" class="btn btn-primary-gra" onclick="javascript:goMbo();">마케팅 MBO확인</button>
							</div>
						</div>
					</div>
					<div id="auiGridLeft" style="margin-top: 5px;height: 485px;"></div>
					<div class="btn-group mt5 ">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt_left">0</strong>건
						</div>
					</div>
				</div>
				<!-- /메뉴목록 -->
				<div class="col-9" style="margin-top: -5px;">
					<div class="row">
						<!-- 메뉴정보 -->
						<div class="col-12">
							<div class="title-wrap mt10">
								<div class="btn-group">
									<h4>RSP목록 </h4>
									<div class="right">
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
							<div class="btn-group mt5 ">
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