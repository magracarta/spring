<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-24 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid(); // 메인 그리드
			// fnInit();
		});

// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -5));
// 		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_item_id", "s_item_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 조회
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_start_dt", "s_end_dt"]}) == false) {
				return;
			}

			var params = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_item_id": $M.getValue("s_item_id"),
				"s_item_name": $M.getValue("s_item_name"),
				"s_cust_name" : $M.getValue("s_cust_name"),
				"s_com_buy_group_cd": $M.getValue("s_com_buy_group_cd"),
				"s_part_production_cd": $M.getValue("s_part_production_cd"),
				"s_proc_status" : $M.getValue("s_proc_status"),	// 2024.05.27 처리상태 추가 [다은]
			};
			_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);

							for(var i in result.list) {
								var row = result.list[i];
								var arr = [];

								if("" != row.invoice_file_seq) {
									arr.push("in");
								}

								if("" != row.import_file_seq) {
									arr.push("il");
								}

								if("" != row.bl_file_seq) {
									arr.push("bl");
								}

								row["download"] = arr.join(",");
							}
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
			fnExportExcel(auiGrid, "부품매입관리");
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
				rowIdField : "_$uid",
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// rowNumber 
				showRowNumColumn: true,
				editable : false,
				showSelectionBorder : false
			};
			var columnLayout = [
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no",
					width : "85",
					minWidth : "85",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					},
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "부품명", 
					dataField : "item_name",
					width : "230",
					minWidth : "230",
					style : "aui-left",
				},
				{
					headerText : "매입처", 
					dataField : "client_cust_name", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
				},
				{
					headerText : "입고일", 
					dataField : "inout_dt",
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "65",
					minWidth : "65",
					style : "aui-center",
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					dataType : "numeric",
					formatString : "#,##0", 
					width : "50",
					minWidth : "50",
					style : "aui-center",
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price", 
					dataType : "numeric",
					formatString : "#,##0", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
				},
				{ 
					headerText : "금액", 
					dataField : "amt", 
					dataType : "numeric",
					formatString : "#,##0", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
				},
				{ 
					headerText : "VAT", 
					dataField : "vat_amt", 
					dataType : "numeric",
					formatString : "#,##0", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
				},
				{ 
					headerText : "합계", 
					dataField : "tot_amt",
					dataType : "numeric",
					formatString : "#,##0", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
				},
				{ 
					headerText : "비고", 
					dataField : "desc_text",
					width : "200",
					minWidth : "200",
					style : "aui-left",
				},
				{
					headerText : "처리상태",
					dataField : "proc_status",
					width : "90",
					minWidth : "90",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var procStatus;
						if(item.proc_status == "00") {
							procStatus = "저장";
						} else if(item.proc_status == "01") {
							procStatus = "정산요청";
						} else {
							procStatus = "정산완료";
						}
						return procStatus;
					},
				},
				{ 
					headerText : "매입자", 
					dataField : "reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "계약납기일", 
					dataField : "delivary_dt",
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "65",
					minWidth : "65",
					style : "aui-center",
				},
				{ 
					headerText : "발주일자", 
					dataField : "order_proc_dt",
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "65",
					minWidth : "65",
					style : "aui-center",
				},
				{ 
					headerText : "발주번호", 
					dataField : "part_order_no", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var orderNo = value;
						return orderNo.substring(4, 16);
					},
				},
				{
					headerText : "발주자", 
					dataField : "order_reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "인보이스 파일번호",
					dataField : "invoice_file_seq",
					visible : false
				},
				{
					headerText : "수입면장 파일번호",
					dataField : "import_file_seq",
					visible : false
				},
				{
					headerText : "BL 파일번호",
					dataField : "bl_file_seq",
					visible : false
				},
				{
					headerText: "다운로드",
					dataField: "download",
					width : "6%",
					minWidth : "90",
					editable: false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer: { // HTML 템플릿 렌더러 사용
						type: "TemplateRenderer",
						aliasFunction: function (rowIndex, columnIndex, value, headerText, item) { // 엑셀, PDF 등 내보내기 시 값 가공 함수
							return value.replace('in', "IN").replace('bl', "BL").replace('il', "IL").replace(/,/g, "/");
						}
					},
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) { // HTML 템플릿 작성
						var valueArr = value == "" ? "" : value.split(",");
						var inputTagArr = [];
						var template = '<div>';
						template += '<span>';
						if(item.invoice_file_seq != "") {
							inputTagArr[0] = '<button type="button" class="btn btn-default mr10" value="in_btn" onclick="javascript:fnClickCheck(' + rowIndex + ', 1' + ');">IN';
						}
						if(item.bl_file_seq != "") {
							inputTagArr[1] = '<button type="button" class="btn btn-default mr10" value="bl_btn" onclick="javascript:fnClickCheck(' + rowIndex + ', 2' + ');">BL';
						}
						if(item.import_file_seq != "") {
							inputTagArr[2] = '<button type="button" class="btn btn-default" value="il_btn" onclick="javascript:fnClickCheck(' + rowIndex + ', 3' + ');">IL';
						}
						for (var i = 0, len = valueArr.length; i < len; i++) {
							switch (valueArr[i]) {
								case "in_btn":
									inputTagArr[0] = '<button type="button" class="btn btn-default mr10" value="in_btn" onclick="javascript:fnClickCheck(' + rowIndex + ', 1' + ');">IN';
									break;
								case "bl_btn":
									inputTagArr[1] = '<button type="button" class="btn btn-default mr10" value="bl_btn" onclick="javascript:fnClickCheck(' + rowIndex + ', 2' + ');">BL';
									break;
								case "il_btn":
									inputTagArr[2] = '<button type="button" class="btn btn-default" value="il_btn" onclick="javascript:fnClickCheck(' + rowIndex + ', 3' + ');">IL';
									break;
							}
						}
						template += inputTagArr.join('');
						template += '</span>';
						template += '</div>';
						return template;
					}
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();
			
			AUIGrid.bind("#auiGrid", "cellClick", function(event) {
				if(event.dataField == 'download') {
					fn_curGrid_shadow(event.pid);
					
				} else if(event.dataField == "inout_doc_no") {
					var params = {
						"inout_doc_no" : event.item.inout_doc_no
					};

					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1060, height=690, left=0, top=0";
					$M.goNextPage("/part/part0302p05", $M.toGetParam(params), {popupStatus : poppupOption});
				}
			});
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
								<col width="50px">
								<col width="120px">
								<col width="50px">
								<col width="120px">
								<col width="50px">
								<col width="120px">
								<col width="60px">
								<col width="180px">
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>입고일자</th>
								<td>
									<div class="row mg0">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="변경 시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="변경 종료일" value="${searchDtMap.s_end_dt}">
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
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control" id="s_item_id" name="s_item_id">
								</td>
								<th>부품명</th>
								<td>
									<input type="text" class="form-control" id="s_item_name" name="s_item_name">
								</td>
								<th>매입처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" placeholder="" id="s_cust_name" name="s_cust_name" value="">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th>업체그룹</th>
								<td>
									<select class="form-control" id="s_com_buy_group_cd" name="s_com_buy_group_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['COM_BUY_GROUP']}">
											<option value="${item.code_value}">${item.code_desc}</option>
										</c:forEach>
									</select>
								</td>
								<th>생산구분</th>
								<td>
									<select class="form-control" id="s_part_production_cd" name="s_part_production_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['PART_PRODUCTION']}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>처리상태</th>
								<td>
									<select class="form-control" id="s_proc_status" name="s_proc_status">
										<option value="">전체</option>
										<option value="00">저장</option>
										<option value="01">정산요청</option>
										<option value="02">정산완료</option>
									</select>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
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