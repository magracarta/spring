<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품호환성관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2021-07-12 19:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var rowIndex;
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid(); // 메인 그리드
			goSearch();
		});

		// 조회
		function goSearch() {
			var frm = document.main_form;

			var params = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_sort_key": "c.upload_dt",
				"s_sort_method": "desc",
				"s_machine_plant_seq": $M.getValue("s_machine_plant_seq")
			};
			_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);

// 							for(var i in result.list) {
// 								var row = result.list[i];
// 								var arr = [];

// 								if("" != row.invoice_file_seq) {
// 									arr.push("in");
// 								}

// 								if("" != row.import_file_seq) {
// 									arr.push("il");
// 								}

// 								if("" != row.bl_file_seq) {
// 									arr.push("bl");
// 								}

// 								row["download"] = arr.join(",");
// 							}
							AUIGrid.setGridData(auiGrid, result.list);

// 							var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid,true);
// 							AUIGrid.setColumnSizeList(auiGrid,colSizeList);
						}
					}
			);
		}

		function goPopupPart() {
			var params = {};

			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1060, height=690, left=0, top=0";
			$M.goNextPage("/part/part0302p04", $M.toGetParam(params), {popupStatus : poppupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품호환성관리");
		}

		function goBuyProcess() {
			var params = {};

			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1060, height=690, left=0, top=0";
			$M.goNextPage("/part/part0302p01", $M.toGetParam(params), {popupStatus : poppupOption});
		}

		// 매입처조회
		function fnSearchClientComm() {
			var param = {
				's_cust_name' : $M.getValue('s_cust_name')
			};
			openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
		}

		// 매입처 조회 팝업 클릭 후 리턴
		function setSearchClientInfo(row) {
			$M.setValue("s_cust_name", row.cust_name);
		}

		// 버튼 클릭
		function fnClickCheck(rowIndex, value) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);

			if(value == '1') {
				fileDownload(item.invoice_file_seq);
			}

			if(value == '2') {
				fileDownload(item.bl_file_seq);
			}

			if(value == '3') {
				fileDownload(item.import_file_seq);
			}
		}

		function createAUIGrid() {
			//그리드 생성 _ 선택사항
			var gridPros = {
				rowIdField : "machine_plant_seq",
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// rowNumber 
				showRowNumColumn: true,
				editable : true,
				showSelectionBorder : false
			};

			var useList = [
				{use_yn : "Y", use_name : "사용"},
				{use_yn : "N", use_name : "미사용"}
			];
			
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name",
					width : "200",
					minWidth : "200",
					editable : false,
					style : "aui-center aui-popup"
				},
				{ 
					dataField : "maker_cd",
					editable : false,
					visible : false
				},
				{ 
					dataField : "machine_plant_seq",
					editable : false,
					visible : false
				},
				{
					headerText : "모델", 
					dataField : "machine_name",
					editable : false,
					width : "200",
					minWidth : "200",
					style : "aui-center",
				},
				{
				    headerText: "사용여부",
					children : [
						{
							headerText : "마케팅",
							dataField : "sale_yn",
							width : "120",
							minWidth : "120",
							style : "aui-center",
							editable : false,
							editRenderer : {
								type : "DropDownListRenderer",
								showEditorBtn : false,
								showEditorBtnOver : false,
								editable : false,
								list : useList,
								keyField : "use_yn",
								valueField  : "use_name",
							},
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = value;
								for(var j = 0; j < useList.length; j++) {
									if(useList[j]["use_yn"] == value) {
										retStr = useList[j]["use_name"];
										break;
									}
								}
								return retStr;
							},
						}, 
						{
							headerText : "부품",
							dataField : "part_comm_yn",
							width : "120",
							minWidth : "120",
							style : "aui-center aui-editable",
							editRenderer : {
								type : "DropDownListRenderer",
								showEditorBtn : false,
								showEditorBtnOver : false,
								editable : true,
								list : useList,
								keyField : "use_yn",
								valueField  : "use_name",
							},
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = value;
								for(var j = 0; j < useList.length; j++) {
									if(useList[j]["use_yn"] == value) {
										retStr = useList[j]["use_name"];
										break;
									}
								}
								return retStr;
							},
						},
					]
				},
				{
					headerText : "버전", 
					dataField : "part_ver",
					editable : false,
					width : "280",
					minWidth : "280",
					style : "aui-center",
				},
				{ 
					headerText : "업로드 일자", 
					dataField : "upload_dt", 
					dataType : "date",
					formatString : "yy-mm-dd", 
					editable : false,
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{ 
					headerText : "호환성 파일업로드", 
					dataField : "up_btn", 
					editable : false,
					width : "120",
					minWidth : "120",
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
						var template = '<button type="button" class="aui-grid-button-renderer" style="width: 75px" " onclick="javascript:gofileUpload(\'' + item.machine_plant_seq + '\', \'' + item.machine_name + '\', \'' + rowIndex + '\');">파일업로드</button>' + '</div>';
						return template;
					}
				},
				{ 
					dataField : "part_comm_up_seq",
					editable : false,
					visible : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();
			
			AUIGrid.bind("#auiGrid", "cellClick", function(event) {
				if(event.dataField == 'maker_name') {
					var param = {
							"maker_cd" : event.item["maker_cd"]
					}
					
					var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=1000, left=0, top=0";
					$M.goNextPage("/part/part0707p01", $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
		
		// 파일업로드 팝업
		function gofileUpload(machinePlantSeq, machineName, rowIdx) {
			rowIndex = rowIdx;
			
			var param = {
					"machine_plant_seq" : machinePlantSeq,
					"machine_name" : machineName,
					"parent_js_name" : "setPartComm"
			}
			
			var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=800, left=0, top=0";
			$M.goNextPage("/part/part0707p02", $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		// 파일업로드 데이터 세팅		
		function setPartComm(data) {
		    AUIGrid.updateRow(auiGrid, { "part_ver" : data.part_ver }, rowIndex);
		    AUIGrid.updateRow(auiGrid, { "upload_dt" : data.upload_dt }, rowIndex);
		    AUIGrid.updateRow(auiGrid, { "part_comm_up_seq" : data.part_comm_up_seq }, rowIndex);
		}
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			var machinePlantSeqArr = [];
	        var partCommYnArr = [];
			
			var editRows = AUIGrid.getEditedRowItems(auiGrid);
			
			var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);

			for (var i = 0; i < editRows.length; i++) {
				machinePlantSeqArr.push(editRows[i].machine_plant_seq);
				partCommYnArr.push(editRows[i].part_comm_yn);
			}
			
			var option = {
					isEmpty : true
			};
			
			$M.setValue(frm, "machine_plant_seq_str", $M.getArrStr(machinePlantSeqArr, option));
			$M.setValue(frm, "part_comm_yn_str", $M.getArrStr(partCommYnArr, option));

			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
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
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="270px">
								<col width="60px">
								<col width="180px">
								<col width="60px">
								<col width="180px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>업로드일</th>
								<td>
									<div class="row mg0">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="검색 시작일" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="검색 종료일" value="">
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
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['MAKER']}">
											<c:if test="${item.code_v2 == 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>모델</th>
								<td>		
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
				                     		<jsp:param name="required_field" value=""/>
				                     		<jsp:param name="s_maker_cd" value=""/>
				                     		<jsp:param name="s_machine_type_cd" value=""/>
				                     		<jsp:param name="s_sale_yn" value=""/>
				                     		<jsp:param name="readonly_field" value=""/>
				                     		<jsp:param name="execFuncName" value=""/>
				                     		<jsp:param name="focusInFuncName" value=""/>
				                     	</jsp:include>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
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
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>

			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>