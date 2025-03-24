<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 출하시임의비용처리 > 원가 미 반영 > null
-- 작성자 : 정재호
-- 최초 작성일 : 2022-11-11 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var costItemJson = JSON.parse('${codeMapJsonObj['COST_ITEM']}');
		
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
			fnInit();
		});
		
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
		}
		
		//조회
		function goSearch() { 
			var param = {
					"s_sort_key" : "machine_doc_no", 
					"s_sort_method" : "asc",
					"s_cost_proc_yn" : $M.getValue("s_cost_proc_yn"),
					"s_cost_item_cd" : $M.getValue("s_cost_item_cd"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_reg_mem_name" : $M.getValue("s_reg_mem_name"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax("/acnt/acnt0406" + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_reg_mem_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				showStateColumn : true,
				editable : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				softRemoveRowMode : true,
				rowStyleFunction : function(rowIndex, item) {
					 if(item.cost_proc_yn == "Y") {
						 // 처리일 때
						 return "aui-row-part-sale-end";
					 }
					 return "";
				}
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-popup",
					editable : false,
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "") {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  }
	                   return ret;
	               },
				},
				{
					dataField : "seq_no",
					visible : false
				},
				{
					headerText : "출하일자",
					dataField : "out_dt",
					width : "75",
					minWidth : "75",
					editable : false,
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "100",
					minWidth : "100",
					editable : false,
					style : "aui-left",
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "150",
					minWidth : "150",
					editable : false,
					style : "aui-center",
				},
				{
					headerText : "차주명",
					dataField : "machine_cust_name",
					width : "120",
					minWidth : "110",
					editable : false,
					style : "aui-center"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "110",
					minWidth : "100",
					editable : false,
					style : "aui-center",
				},
				{
					headerText : "판매자명",
					dataField : "reg_mem_name",
					width : "75",
					minWidth : "75",
					editable : false,
					style : "aui-center",
				},
// 				{
// 					headerText : "연락처",
// 					dataField : "hp_no",
// 					width : "8%",
// 					editable : false,
// 					style : "aui-center"
// 				},
				{
					headerText : "구분",
					dataField : "cost_item_cd",
					width : "80",
					minWidth : "70",
					style : "aui-center  aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : costItemJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < costItemJson.length; j++) {
							if(costItemJson[j]["code_value"] == value) {
								retStr = costItemJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					}
				},
				{
					headerText : "적요",
					dataField : "cost_name",
					width : "210",
					minWidth : "100",
					style : "aui-left aui-editable"
				},
				{
					headerText : "금액",
					dataField : "amt",
					width : "90",
					minWidth : "85",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-editable"
				},
				{
					headerText : "처리구분",
					dataField : "cost_proc_yn",
					width : "70",
					minWidth : "70",
					editable : false,
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item["cost_proc_yn"] == "Y" ? "처리" : "미결";
					}
				},
				{
					headerText : "처리일자",
					dataField : "cost_proc_dt",
					width : "75",
					minWidth : "75",
					editable : false,
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "처리자",
					dataField : "cost_proc_mem_name",
					editable : false,
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "60",
					minWidth : "50",
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
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
							// 삭제버튼은 행 추가시에만 보이게 함
							if(AUIGrid.isAddedById("#auiGrid", item._$uid)) {
							  	return true;
							}
							else {
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
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 에디팅 시작 이벤트 바인딩
			 AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
			   if(event.item["cost_proc_yn"] == "Y" ) {
				   return false; // false 반환. 기본 행위인 편집 불가
			   }
			 });
			// 관리번호 클릭시 -> 계약 품의서 상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_doc_no") {
					var params = {
							"machine_doc_no" : event.item["machine_doc_no"]
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}

		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
					// 제외항목
					exceptColumnFields : ["removeBtn"]
			  };
			  fnExportExcel(auiGrid, "출하시임의비용처리_원가미반영", exportProps);
		}

		function fnChangeCostProcYn(costProcYn) {
			if(costProcYn == "Y") {
				$("#date_name").text("처리일자");
			} else {
				$("#date_name").text("출하일자");
			}
		}

		// 지급 처리
		function goCostProcess() {
			var data = AUIGrid.getGridData(auiGrid);
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			for(var i = 0; i < data.length; i++) {
				if(AUIGrid.isAddedById("#auiGrid", data[i]._$uid)) {
					alert("신규 등록한 내용을 먼저 저장해주십시오.");
				  	return false;
				}
			}
				var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("선택된 데이터가 없습니다.");
				return false;
			}
			// 지급처리 아닌 건만 하기
			for (var i = 0; i < rows.length; i++) {
				if(rows[i].cost_proc_yn == "Y") {
					alert("지급처리되지 않은 건만 체크해주세요.");
					return false;
				}
			}
			var machineDocNoArr = [];
			var seqNoArr = [];
			var cmdArr = [];
			var costProcYnArr = [];
			var costItemCdArr = [];
			var costNameArr = [];
			var amtArr = [];
			for (var i = 0; i < rows.length; ++i) {
				machineDocNoArr.push(rows[i].machine_doc_no);
				seqNoArr.push(rows[i].seq_no);
				costItemCdArr.push(rows[i].cost_item_cd);
				costNameArr.push(rows[i].cost_name);
				amtArr.push(rows[i].amt)
				cmdArr.push("U");
				costProcYnArr.push("Y");
			}
 			var param = {
 					machine_doc_no_str : $M.getArrStr(machineDocNoArr),
 					cost_item_cd_str : $M.getArrStr(costItemCdArr),
 					cost_name_str : $M.getArrStr(costNameArr),
 					amt_str : $M.getArrStr(amtArr),
 					seq_no_str : $M.getArrStr(seqNoArr),
 					cmd_str : $M.getArrStr(cmdArr),
 					cost_proc_yn_str : $M.getArrStr(costProcYnArr),
			}

			var result = confirm("지급 처리 하시겠습니까?");
			if (!result) {
				return false;
	        }
			$M.goNextPageAjax("/acnt/acnt0406" + "/cost", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						AUIGrid.clearGridData(auiGrid);
						goSearch();
					};
				}
			);
		}

		// 지급 취소
		function goCancelCostProcess() {
			var data = AUIGrid.getGridData(auiGrid);
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			for(var i = 0; i < data.length; i++) {
				if(AUIGrid.isAddedById("#auiGrid", data[i]._$uid)) {
					alert("신규 등록한 내용을 먼저 저장해주십시오.");
				  	return false;
				}
			}
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("선택된 데이터가 없습니다.");
				return false;
			}
			// 지급처리 된 건만 취소하기
			for (var i = 0; i < rows.length; i++) {
				if(rows[i].cost_proc_yn != "Y") {
					alert("지급처리된 건만 취소할 수 있습니다.");
					return false;
				}
			}
			var machineDocNoArr = [];
			var seqNoArr = [];
			var cmdArr = [];
			var costProcYnArr = [];
// 			var costItemCdArr = [];
// 			var costNameArr = [];
// 			var amtArr = [];
			for (var i = 0; i < rows.length; ++i) {
				machineDocNoArr.push(rows[i].machine_doc_no);
				seqNoArr.push(rows[i].seq_no);
// 				costItemCdArr.push(rows[i].cost_item_cd);
// 				costNameArr.push(rows[i].cost_name);
// 				amtArr.push(rows[i].amt)
				cmdArr.push("U");
				costProcYnArr.push("N");
			}
 			var param = {
 					machine_doc_no_str : $M.getArrStr(machineDocNoArr),
//  					cost_item_cd_str : $M.getArrStr(costItemCdArr),
//  					cost_name_str : $M.getArrStr(costNameArr),
//  					amt_str : $M.getArrStr(amtArr),
 					seq_no_str : $M.getArrStr(seqNoArr),
 					cmd_str : $M.getArrStr(cmdArr),
 					cost_proc_yn_str : $M.getArrStr(costProcYnArr),
			}

			var result = confirm("지급 취소 하시겠습니까?");
			if (!result) {
				return false;
	        }

			$M.goNextPageAjax("/acnt/acnt0406" + "/costCancel", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						AUIGrid.clearGridData(auiGrid);
						goSearch();
					};
				}
			);
		}

		function goCostPopup() {
			var params = {
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=350, left=0, top=0";
			$M.goNextPage('/acnt/acnt0406p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnSetOppCost(data) {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "cost_item_cd");
			fnSetCellFocus(auiGrid, colIndex, "cost_item_cd");
			var row = new Object();
				row.machine_doc_no = data.machine_doc_no;
				row.out_dt = data.out_dt;
				row.machine_name = data.machine_name;
				row.body_no = data.body_no;
				row.machine_cust_name = data.machine_cust_name;
				row.reg_mem_name = data.reg_mem_name;
				row.cust_name = data.cust_name;
				row.hp_no = $M.phoneFormat(data.hp_no);
				row.cost_item_cd = '';
				row.cost_name = '';
				row.amt = '';
				row.cost_proc_yn = 'N';
				row.cost_proc_dt = '';
				row.cost_proc_mem_name = '';
				AUIGrid.addRow(auiGrid, row, "first");

				var data = AUIGrid.getGridData(auiGrid);
				var item = [data[0]._$uid];

				AUIGrid.addCheckedRowsByIds(auiGrid, item);

		}

		// 그리드 빈값 체크
		function isValid() {
			// 추후 필수체크 (현재 데이터 없음)
			// return AUIGrid.validateGridData(auiGrid, ["machine_doc_no", "out_dt", "reg_mem_name", "machine_name", "body_no", "cust_name", "hp_no", "cost_item_cd", "cost_name", "amt"], "필수 항목는 반드시 값을 입력해야 합니다.");
			return AUIGrid.validateGridData(auiGrid, ["machine_doc_no", "cost_item_cd", "cost_name", "amt"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}

		// 저장
		function goSave() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("선택된 데이터가 없습니다.");
				return false;
			}
			for(var i = 0; i < rows.length; i++) {
				if(rows[i].cost_item_cd == '') {
					alert("구분은 반드시 값을 입력해야합니다.");
					return false;
				}
				if(rows[i].cost_name == '') {
					alert("적요는 반드시 값을 입력해야합니다.");
					return false;
				}
				if(rows[i].cost_proc_yn == 'Y') {
					alert("지급처리된 건은 수정할 수 없습니다.");
					return false;
				}
			}

			for(var i = 0; i < rows.length; i++) {
				for(var j = 0; j < i; j++) {
					if(rows[i].machine_doc_no == rows[j].machine_doc_no) {
						if(rows[i].cost_item_cd != "12") {
							if(rows[i].cost_item_cd == rows[j].cost_item_cd) {
								alert("동일한 품의서에 중복된 임의비용구분이 있습니다.");
								return false;
							}
						}
					}
				}
			}

			var machineDocNoArr = [];
			var costItemCdArr = [];
			var costNameArr = [];
			var amtArr = [];
			var costProcYnArr = [];
			var cmdArr = [];
			var seqNoArr = [];

			for (var i = 0; i < rows.length; ++i) {
				machineDocNoArr.push(rows[i].machine_doc_no);
				costItemCdArr.push(rows[i].cost_item_cd);
				costNameArr.push(rows[i].cost_name);
				amtArr.push(rows[i].amt);
				costProcYnArr.push(rows[i].cost_proc_yn);
				seqNoArr.push(rows[i].seq_no);
				if(AUIGrid.isAddedById("#auiGrid", rows[i]._$uid)) {
					cmdArr.push("C");
				} else if(rows[i].seq_no != 0){
					cmdArr.push("U");
				}
			}
			var option = {
					isEmpty : true
			};
 			var param = {
 					machine_doc_no_str : $M.getArrStr(machineDocNoArr, option),
 					cost_item_cd_str : $M.getArrStr(costItemCdArr, option),
 					cost_name_str : $M.getArrStr(costNameArr, option),
 					amt_str : $M.getArrStr(amtArr, option),
 					cost_proc_yn_str : $M.getArrStr(costProcYnArr, option),
 					cmd_str : $M.getArrStr(cmdArr, option),
 					seq_no_str : $M.getArrStr(seqNoArr, option),
					this_page : this_page
			}
			$M.goNextPageAjaxSave("/acnt/acnt0406" + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			AUIGrid.clearGridData(auiGrid);
		    			goSearch();
					}
				}
			);
		}

		// 선택한 로우 삭제
		function fnRemove() {
			// 상단 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			};
			var data = AUIGrid.getGridData(auiGrid);
			for(var i = 0; i < data.length; i++) {
				if(AUIGrid.isAddedById("#auiGrid", data[i]._$uid)) {
					alert("신규 등록한 내용을 먼저 저장해주십시오.");
				  	return false;
				}
			}
			for(var i = 0; i < rows.length; i++) {
				if(rows[i].cost_proc_yn == 'Y') {
					alert("지급처리된 건은 삭제할 수 없습니다.");
					return false;
				}
			}
			var machineDocNoArr = [];
			var seqNoArr = [];
			var cmdArr = [];
			for (var i = 0; i < rows.length; ++i) {
				machineDocNoArr.push(rows[i].machine_doc_no);
				seqNoArr.push(rows[i].seq_no);
				cmdArr.push("U");
			}
 			var param = {
 					machine_doc_no_str : $M.getArrStr(machineDocNoArr),
 					seq_no_str : $M.getArrStr(seqNoArr),
 					cmd_str : $M.getArrStr(cmdArr),
			}

			$M.goNextPageAjaxRemove("/acnt/acnt0406" + "/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						AUIGrid.clearGridData(auiGrid);
						goSearch();
					};
				}
			);
			// 선택한 상단 그리드 행들 삭제
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
// 			AUIGrid.removeCheckedRows(auiGrid);
		}
		
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="75px">
								<col width="260px">
								<col width="70px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="75px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>처리구분</th>
									<td>
										<select class="form-control" id="s_cost_proc_yn" name="s_cost_proc_yn" onchange="javascript:fnChangeCostProcYn(this.value);">
											<option value="">- 전체 -</option>
											<option value="Y">처리</option>
											<option value="N" selected="selected">미결</option>
										</select>
									</td>
									<th id="date_name">출하일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" alt="요청 시작일"  required="required">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="요청 종료일"  required="required">
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
									<th>자료구분</th>
									<td>
										<select class="form-control" id="s_cost_item_cd" name="s_cost_item_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['COST_ITEM']}">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>고객명</th>
									<td>
										<input type="text" class="form-control width120px" id="s_cust_name" name="s_cust_name">
									</td>
									<th>판매자명</th>
									<td>
										<input type="text" class="form-control width120px" id="s_reg_mem_name" name="s_reg_mem_name">
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>				
				</div>
			</div>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>