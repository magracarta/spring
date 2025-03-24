<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 신차계약 서류관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
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
			goSearch();
		});
		
		function goSendPaperSms(rowIndex, paperYn) {
			
			var type = "계약"; // 쪽지 열 페이지
			var item = AUIGrid.getGridData(auiGrid)[rowIndex];
			var array = [];
			var afterArray = [];

			if(item.before_yn == "N") {
				if (item.itg_pass_yn == "" || item.itg_pass_yn == "N") {
					array.push("통합계약서");
				}
			} else {
				// 장비계약서 필수
				if (item.con_pass_yn == "" || item.con_pass_yn == "N") {
					array.push("장비계약서");
				}

				// CAP 계약서
				if (item.cap_pass_yn == "N") {
					array.push("CAP계약서");
				} else {
					if (item.cap_yn == "Y") {
						if (item.cap_pass_yn == "") {
							array.push("CAP계약서");
						}
					}
				}

				// SA-R 계약서
				if (item.sar_pass_yn == "N") {
					array.push("SA-R계약서");
				} else {
					if (item.sar_yn == "Y") {
						if (item.sar_pass_yn == "") {
							array.push("SA-R계약서");
						}
					}
				}
			}

			// 개인정보동의서 필수
			if (item.pvt_pass_yn == "" || item.pvt_pass_yn == "N") {
				array.push("개인정보동의서");
			}
			
			// 사업자등록증
			if (item.brg_pass_yn == "N") {
				array.push("사업자등록증");
			}
			
			// DI리포트
			if (item.di_pass_yn == "N") {
				afterArray.push("DI리포트");
				type = "출고";
			} else {
				if (item.di_yn == "Y") {
					if (item.di_pass_yn == "") {
						afterArray.push("DI리포트");
						type = "출고";
					}
				}
			}
			
			// Commissioning리포트
			if (item.cms_pass_yn == "N") {
				afterArray.push("Commissioning리포트");
				type = "출고";
			} else {
				if (item.cms_yn == "Y") {
					if (item.cms_pass_yn == "") {
						afterArray.push("Commissioning리포트");
						type = "출고";
					}
				}
			}
			
			console.log(array.join(", "), afterArray.join(", "));
			
			var invalidDoc = array.join(", ");
			var invalidAfterDoc = afterArray.join(", ");
			
			// var msg = "영업사원("+item.doc_mem_name+")에게 서류제출요청 쪽지와 문자를 보내시겠습니까?\n";
			// if (invalidDoc != "") {
			// 	msg += "출하전 요청서류 - "+invalidDoc+"\n";
			// }
			// if (invalidAfterDoc != "") {
			// 	msg += "출하후 요청서류 - "+invalidAfterDoc+"\n";
			// }

			var msg = $M.getCurrentDate('yyyy-MM-dd') + "\n"
					+ item.cust_name + " 고객님의 \n";
			if(invalidDoc != "") {
				msg += "출하전 요청서류 - " + invalidDoc + "\n";
			}
			if(invalidAfterDoc != "") {
				msg += "출하후 요청서류 - "+invalidAfterDoc+"\n";
			}
			msg += "를 빠른 시일내에 제출 해주시기 바랍니다.";

			if(paperYn == 'Y') {
				var jsonObject = {
					"paper_contents" : msg,
					"ref_key" : item.machine_doc_no,
					"receiver_mem_no_str" : item.doc_mem_no,	// 수신자
					"refer_mem_no_str" : "",		// 참조자
					"menu_seq" : invalidDoc != "" ? "${doc_menu_seq}" : "${after_doc_menu_seq}",
					"pop_get_param" : "machine_doc_no="+item.machine_doc_no
				}
				openSendPaperPanel(jsonObject);
			} else {
				var param = {
					"name" : item.doc_mem_name,
					"hp_no" : item.hp_no,
					"page_msg_yn" : "Y",
					"page_contents" : msg,
				}
				openSendSmsPanel($M.toGetParam(param));
			}

			// if (confirm(msg) == false) {
			// 	return false;
			// }

			// var param = {
			// 	machine_doc_no : item.machine_doc_no,
			// 	cust_name : item.cust_name,
			// 	doc_mem_no : item.doc_mem_no,
			// 	invalid_doc : invalidDoc,
			// 	type : type
			// };
			//
			// $M.goNextPageAjax(this_page + "/send", $M.toGetParam(param), {method : 'post'},
			// 		function(result) {
			// 			if(result.success) {
			//
			// 			};
			// 		}
			// 	);
		}
		
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			};
		  	fnExportExcel(auiGrid, "신차계약 서류관리", exportProps);
		}	
		
		function goSearch() {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			}; 
			var param = {
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_cust_name" : $M.getValue("s_cust_name"),
				"s_org_code" : $M.getValue("s_org_code"),
				"s_mem_name" : $M.getValue("s_mem_name"),
				"s_complete_yn" : $M.getValue("s_complete_yn"),
				"s_search_type" : $M.getValue("s_search_type"),
				"s_sort_key" : "doc_dt",
				"s_sort_method" : "desc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
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
			var field = ["s_cust_name", "s_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "machine_doc_no",
				showRowNumColumn: true,
				enableCellMerge: true, // 셀병합 사용여부
				height : 550,
				editable : false,
			};
			var columnLayout = [
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "doc_mem_no",
					visible : false
				},
				{
					dataField : "hp_no",
					visible : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "100", 
					minWidth : "45",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "80", 
					minWidth : "45",
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "140", 
					minWidth : "40",
					style : "aui-center"
				},
				{ 
					headerText : "계약일", 
					dataField : "doc_dt", 
					width : "80", 
					minWidth : "45",
					dataType : "date",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "출하일", 
					dataField : "out_dt",
					width : "80", 
					minWidth : "45",
					dataType : "date",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
					headerText : "마케팅담당자",
					dataField : "doc_mem_name", 
					width : "60", 
					minWidth : "45",
					style : "aui-center"
				},
				{
					headerText : "출하 전 제출서류",
					style : "my-column-style",
					headerStyle : "my-column-style",
					children : [
						{
							dataField : "itg_pass_yn", // 필수
							headerText : "통합계약서",
							width : "80",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if(item.before_yn == "Y") {
									return "";
								}

								if (value == "") {
									return "X";
								} else if (value == "N") {
									return "부적합";
								} else if(value == "P") {
									return "O(확인요망)";
								} else {
									return "O(적합)";
								}
							},
						},
						{
							dataField : "con_pass_yn", // 필수
							headerText : "장비계약서",
							width : "80",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if(item.before_yn == "N") {
									return "";
								}

								if (value == "") {
									return "X";
								} else if (value == "N") {
									return "부적합";
								} else if(value == "P") {
									return "O(확인요망)";
								} else {
									return "O(적합)";
								}
							},
						},
						{
							dataField : "cap_pass_yn", // CAP일때 필수
							headerText : "CAP계약서",
							width : "80",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if(item.before_yn == "N") {
									return "";
								}

								if (item.cap_yn == "Y") {
									if (value == "") {
										return "X";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								} else {
									if (value == "") {
										return "None";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								}	
							},
						},
						{
							dataField : "sar_pass_yn", // SAR일때 필수
							headerText : "SA-R계약서",
							width : "80",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if(item.before_yn == "N") {
									return "";
								}

								if (item.sar_yn == "Y") {
									if (value == "") {
										return "X";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								} else {
									if (value == "") {
										return "None";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								}	
							},
						},
						{
							dataField : "pvt_pass_yn", // 필수
							headerText : "개인정보동의서",
							width : "90",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if (value == "") {
									return "X";
								} else if (value == "N") {
									return "부적합";
								} else if(value == "P") {
									return "O(확인요망)";
								} else {
									return "O(적합)";
								}
							},
						},
						{
							dataField : "brg_pass_yn", // 필수아님
							headerText : "사업자등록증",
							width : "80",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if (value == "") {
									return "None";
								} else if (value == "N") {
									return "부적합";
								} else if(value == "P") {
									return "O(확인요망)";
								} else {
									return "O(적합)";
								}
							},
						},
					]
				},
				{
					headerText : "출하 후 제출서류",
					style : "my-column-style",
					headerStyle : "my-column-style",
					children : [
						{
							dataField : "di_pass_yn", // DI일때 필수
							headerText : "DI리포트",
							width : "80",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if (item.di_yn == "Y") {
									if (value == "") {
										return "X";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								} else {
									if (value == "") {
										return "None";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								}	
							},
						},
						{
							dataField : "cms_pass_yn",
							headerText : "Commissioning리포트",
							width : "130",
							minWidth : "45",
							style : "aui-center aui-popup",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								if (item.cms_yn == "Y") {
									if (value == "") {
										return "X";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								} else {
									if (value == "") {
										return "None";
									} else if (value == "N") {
										return "부적합";
									} else if(value == "P") {
										return "O(확인요망)";
									} else {
										return "O(적합)";
									}
								}
							},
						},
					]
				},
				{ 
					headerText : "제출관리",
					children : [
						{
							headerText : "쪽지",
							dataField : "tot_complete_yn",
							width : "45",
							minWidth : "40",
							cellColMerge: true, // 셀 가로 병합 실행
							cellColSpan: 2, // 셀 가로 병합 대상은 2개로 설정
							style : "aui-center",
							renderer : { // HTML 템플릿 렌더러 사용
								type : "TemplateRenderer"
							},
							labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
								var template = '<div class="my_div">';
								if (value == "Y") {
									template += '완료'
								} else {
									template += '<div class="aui-grid-renderer-base" style="max-height: 24px;">';
									template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goSendPaperSms(' + rowIndex + ',\'Y\')">전송</span></div>'
								}
								template += '</div>'
								return template; // HTML 형식의 스트링
							},
						},
						{
							headerText : "문자",
							dataField : "tot_complete_yn",
							width : "45",
							minWidth : "40",
							style : "aui-center",
							renderer : { // HTML 템플릿 렌더러 사용
								type : "TemplateRenderer"
							},
							labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
								var template = '<div class="my_div">';
								if (value == "Y") {
									template += '완료'
								} else {
									template += '<div class="aui-grid-renderer-base" style="max-height: 24px;">';
									template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goSendPaperSms(' + rowIndex + ',\'N\')">전송</span></div>'
								}
								template += '</div>'
								return template; // HTML 형식의 스트링
							},
						},
					],
				}
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 직책(job_name) 컬럼고정
			// AUIGrid.setFixedColumnCount(auiGrid, 4);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "itg_pass_yn" || event.dataField == "con_pass_yn" || event.dataField == "cap_pass_yn" || event.dataField == "sar_pass_yn"
						|| event.dataField == "pvt_pass_yn" || event.dataField == "brg_pass_yn") {
					var param = {
						"machine_doc_no" : event.item.machine_doc_no
					};
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
					$M.goNextPage("/sale/sale0101p01", $M.toGetParam(param), {popupStatus : popupOption});
				}
				if (event.dataField == "di_pass_yn" || event.dataField == "cms_pass_yn") {
					var param = {
						"machine_doc_no" : event.item.machine_doc_no
					};
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
					$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : popupOption});
				}
				if (event.dataField == "cust_name") {
					var param = {
						"cust_no" : event.item.cust_no
					};
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
					$M.goNextPage("/cust/cust0102p01", $M.toGetParam(param), {popupStatus : popupOption});
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
	<!-- 기본 -->					
				<div class="search-wrap">				
						<table class="table table-fixed">
							<colgroup>
								<col width="100px">
								<col width="270px">
								<col width="50px">
								<col width="100px">	
								<col width="45px">
								<col width="270px">
								<col width="70px">
								<col width="100px">	
								<col width="65px">
								<col width="80px">	
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<td>
                                        <select class="form-control" name="s_search_type">
                                            <option value="doc" selected="selected">계약일자</option>
                                            <option value="out">출하일자</option>
                                        </select>
                                    </td>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="작성시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="작성종료일">
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
									<th>고객명</th>
									<td>
										<input type="text" class="form-control" name="s_cust_name">
									</td>
									<th>부서</th>
									<td>
										<input class="form-control" style="width: 99%;"type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
												easyuiname="pathOrgList" panelwidth="350" idfield="org_code" textfield="path_org_name" multi="N"/>
									</td>
									<th>담당자명</th>
									<td>
										<input type="text" class="form-control" name="s_mem_name">
									</td>
									<th>제출구분</th>
									<td>
										<select class="form-control" name="s_complete_yn">
                                            <option value="">- 전체 -</option>
                                            <option value="Y">완료</option>
                                            <option value="N">미완료</option>
                                        </select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<span class="text-warning" tooltip="">※ O : 서류확인완료 | X : 필수서류확인안됨 | 부적합 : 서류부적합 | None : 필수서류아님</span>
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
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>