<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동처리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-06 10:01:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
	
		var partTransJson = JSON.parse('${codeMapJsonObj['PART_TRANS_TYPE']}');
		var partTransReqJson = JSON.parse('${codeMapJsonObj['PART_TRANS_REQ_TYPE']}');
		$(document).ready(function() {
// 			fnInitDate();
			createAUIGrid();
			goSearch();
		});
		
		//엑셀다운로드
		function fnExcelDownSec() {
			fnExportExcel(auiGrid, "부품이동처리목록", "");
		}
		
		// 조회
		function goSearch() { 
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}

		// 부품이동처리 목록 조회
		function fnSearch(successFunc) { 
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}; 
			
			var param = {
				s_start_dt 					: $M.getValue("s_start_dt"),
				s_end_dt 					: $M.getValue("s_end_dt"),
				s_end_yn 					: $M.getValue("s_end_yn"),
				s_part_trans_status_cd 		: $M.getValue("s_part_trans_status_cd"),
				s_part_no 					: $M.getValue("s_part_no"),
				s_part_name 				: $M.getValue("s_part_name"),
				s_part_trans_type_cd 		: $M.getValue("s_part_trans_type_cd"),
				s_date_type : $M.getValue("s_date_type"),
				"page" : page,
				"rows" : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}
		
		// 마감취소
		function goCancelDone() {
			goDoneProc('N');
		}
		
		// 마감
		function goDone() {
			goDoneProc('Y');
		}
		
		// 마감처리
		function goDoneProc(endYn) {
			
			var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
			
			if(checkedItems.length <= 0) {
				alert("체크된 값이 없습니다.");
				return;
			};

			var partTransReqNo = [];
			
			if(endYn == 'Y') {
				for(var i=0; i<checkedItems.length; i++) {
					if(checkedItems[i].item.end_yn == 'Y') {
						alert("요청상태가 마감 상태인 자료가 있습니다.");
						return;
					};
					partTransReqNo.push(checkedItems[i].item.part_trans_req_no);
				}
			} else if(endYn == 'N') {
				for(var i=0; i<checkedItems.length; i++) {
					if(checkedItems[i].item.end_yn != 'Y') {
						alert("요청상태가 미마감 상태인 자료가 있습니다.");
						return;
					};
					partTransReqNo.push(checkedItems[i].item.part_trans_req_no);
				}
			};

			var param = {
				'part_trans_req_no_str' : $M.getArrStr(partTransReqNo),
				'endYn'					: endYn,
			};

			var msg = endYn == 'Y' ? '마감 처리하시겠습니까?' : '마감취소 하시겠습니까?';
			
			$M.goNextPageAjaxMsg(msg, this_page + "/endProc", $M.toGetParam(param), {method : 'post'},
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		
		
		// 시작일자 세팅 현재날짜의 1달 전
// 		function fnInitDate() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		function goNew() {
			$M.goNextPage("/part/part020201");
		}

		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				// 체크박스 표시 설정
				showRowCheckColumn : true,
				headerHeight : 40,
				// 전체 선택 체크박스가 독립적인 역할을 할지 여부
				independentAllCheckBox : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : false,
				rowCheckVisibleFunction : function(rowIndex, isChecked, item) {
					if(item.part_trans_req_no != "") { 
						return true;
					}
					return false;
				}
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품이동<br>요청번호",
				    dataField: "part_trans_req_no",
					width : "95",
					minWidth : "90",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != "") {
							return "aui-popup"
						};
						return null;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{
				    headerText: "부품이동<br>처리번호",
				    dataField: "part_trans_no",
					width : "95",
					minWidth : "90",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != "") {
							return "aui-popup"
						};
						return null;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{
				    headerText: "이동요청타입",
				    dataField: "part_trans_type_cd",
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < partTransJson.length; j++) {
							if(partTransJson[j]["code_value"] == value) {
								retStr = partTransJson[j]["code_name"];
								break;
							}
						}
						for(var j = 0; j < partTransReqJson.length; j++) {
							if(partTransReqJson[j]["code_value"] == value) {
								retStr = partTransReqJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
					width : "90",
					minWidth : "90",
					style : "aui-center"
				},
				{
					headerText: "처리일",
				    dataField: "complete_date",
				    dataType : "date",   
					width : "75",
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "230",
					minWidth : "180",
					style : "aui-left"
				},
				{
				    headerText: "요청센터",
				    dataField: "to_warehouse_name",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
				    headerText: "이동요청<br>상태",
				    dataField: "end_yn",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var result = "미마감";
						if(item["end_yn"] == "Y") {
							result = "마감";
						} else if (item["end_yn"] == "" && item["part_trans_status_cd"] == "04") {
							result = "마감";
						}
				    	return result;
					},
					width : "55",
					minWidth : "55",
					style : "aui-center"
				},
				{
				    headerText: "From",
				    dataField: "from_warehouse_name",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
				    headerText: "To",
				    dataField: "to_warehouse_name",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
				    headerText: "처리자",
				    dataField: "reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
				    headerText: "발송구분",
				    dataField: "invoice_send_name",
					width : "75",
					minWidth : "75",
					style : "aui-center aui-popup"
				},
				{
				    headerText: "발송구분 code",
				    dataField: "invoice_send_cd",
				    visible : false,
					style : "aui-center"
				},
				{
				    headerText: "송장타입코드",
				    dataField: "invoice_type_cd",
				    visible : false,
					style : "aui-center"
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "205",
					minWidth : "100",
					style : "aui-left"
				},
				{
				    headerText: "이동처리<br>상태",
				    dataField: "part_trans_status_name",
				    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return $M.nvl(value, '00') == '00' ? "요청전" : value;
					},
					width : "55",
					minWidth : "55",
					style : "aui-center"
				},
				{
				    dataField: "part_trans_status_cd",
				    visible : false,
				},
				{
				    dataField: "send_invoice_seq",
				    visible : false,
				},
				{
				    dataField: "invoice_send_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_type_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_warehouse",
				    visible : false,
				},
				{
				    dataField: "invoice_no",
				    visible : false,
				},
				{
				    dataField: "invoice_qty",
				    visible : false,
				},
				{
				    dataField: "receive_tel_no",
				    visible : false,
				},
				{
				    dataField: "receive_hp_no",
				    visible : false,
				},
				{
				    dataField: "invoice_remark",
				    visible : false,
				},
				{
				    dataField: "invoice_money_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_post_no",
				    visible : false,
				},
				{
				    dataField: "invoice_addr1",
				    visible : false,
				},
				{
				    dataField: "invoice_addr2",
				    visible : false,
				},
				{
				    dataField: "receive_name",
				    visible : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.value == "") {
 					return;
 				};
 				
 				if(event.dataField == "part_trans_no") {
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=600, left=0, top=0";
 					var param = {
 						"part_trans_no" : event.item.part_trans_no,
 					}
					$M.goNextPage("/part/part0202p03", $M.toGetParam(param), {popupStatus : popupOption});
 					
 				} else if(event.dataField == "part_trans_req_no") {
 					if(event.item.part_trans_no == '' && event.item.end_yn == 'Y') {
 						alert('마감된 자료는 열람이 불가능 합니다.');
 						return;
 					};
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=620, left=0, top=0";
 					var param = {
 						"part_trans_req_no" : event.item.part_trans_req_no,
 					}
					$M.goNextPage("/part/part0202p01", $M.toGetParam(param), {popupStatus : popupOption});
 				}
 				else if(event.dataField == "invoice_send_name") {
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=660, left=0, top=0";
 					var param = {
		    			invoice_type_cd 	: event.item.invoice_type_cd,
		    			invoice_money_cd	: event.item.invoice_money_cd,
		    			invoice_send_cd 	: event.item.invoice_send_cd,
		    			receive_name 		: event.item.receive_name,
		    			invoice_no 			: event.item.invoice_no,
		    			receive_hp_no 		: event.item.receive_hp_no,
		    			receive_tel_no 		: event.item.receive_tel_no,
		    			qty 				: event.item.invoice_qty,
		    			remark 				: event.item.invoice_remark,
		    			post_no 			: event.item.invoice_post_no,
		    			addr1				: event.item.invoice_addr1,
		    			addr2				: event.item.invoice_addr2,
		    			show_yn				: 'Y',
					}

					$M.goNextPage("/cust/cust0201p02", $M.toGetParam(param), {popupStatus : popupOption});
 				};

			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
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
									<col width="85px">
									<col width="260px">
									<col width="60px">
									<col width="300px">
									<col width="90px">
									<col width="100px">
									<col width="90px">
									<col width="100px">
									<col width="90px">
									<col width="110px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<td>
										<select class="form-control" id="s_date_type" name="s_date_type">
											<option value="REQ">요청일자</option>
											<option value="TRANS">처리일자</option>
										</select>
										</td>
										<td>
											<div class="form-row inline-pd ">
				                                <div class="col-5">
				                                   <div class="input-group">
				                                      <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청 시작일" value="${searchDtMap.s_start_dt}" >
				                                   </div>
				                                </div>
				                                <div class="col-auto">~</div>
				                                <div class="col-5">
				                                   <div class="input-group">
				                                      <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청 종료일" value="${searchDtMap.s_end_dt}">
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
				                     	<td>부품조회</td>
				                    	<td>
				                    		<jsp:include page="/WEB-INF/jsp/common/searchPart.jsp">
					                     		<jsp:param name="required_field" value=""/>
					                     		<jsp:param name="s_cust_name" value=""/>
					                     		<jsp:param name="s_part_group_name" value=""/>
					                     		<jsp:param name="s_part_mng_cd" value=""/>
					                     		<jsp:param name="readonly_field" value=""/>
					                     		<jsp:param name="execFuncName" value=""/>
					                     		<jsp:param name="focusInFuncName" value=""/>
					                     		<jsp:param name="focusInClearYn" value="Y"/>
					                     	</jsp:include>
				                     	</td>
										<th>이동요청상태</th>
										<td>
											<select class="form-control" id="s_end_yn" name="s_end_yn">
												<option value="">- 전체 -</option>
												<option value="Y">마감</option>
												<option value="N" selected="selected">미마감</option>
											</select>
										</td>
										<th>이동처리상태</th>
										<td>
											<select class="form-control" id="s_part_trans_status_cd" name="s_part_trans_status_cd">
											<option value="">- 전체 -</option>
											<option value="00">요청전</option>
											<option value="01">요청</option>
											<option value="04">완료</option>
											</select>
										</td>
										<th>이동요청타입</th>
										<td>
											<select class="form-control" id="s_part_trans_type_cd" name="s_part_trans_type_cd">
											<option value="">- 전체 -</option>
											<option value="CART">장바구니</option>
											<option value="DIRECT">고객직발송</option>
											<option value="PREDIR">선주문직발송</option>
												<c:forEach var="item" items="${codeMap['PART_TRANS_TYPE']}">
													<option value="${item.code_value}">${item.code_name }</option>
												</c:forEach>
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
							<h4>이동요청내역</h4>
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
						<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div style="margin-top: 5px; height: 555px;" id="auiGrid"></div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">				
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
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