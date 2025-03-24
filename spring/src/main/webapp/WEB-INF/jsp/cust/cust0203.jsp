<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 입출금전표처리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
// 			fnInit();
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
// 		}

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}


		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
			};
			var columnLayout = [
				{
					headerText : "발행일", 
					dataField : "inout_dt", 
					width : "70",
					minWidth : "70",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					width : "85",
					minWidth : "85",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{ 
					headerText : "구분", 
					dataField : "inout_type_name", 
					width : "50",
					minWidth : "50",
					style : "aui-center"
				},
				{ 
					dataField : "inout_type_cd", 
					visible : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "120",
					minWidth : "120",
					style : "aui-center aui-popup",
				},
				{ 
					dataField : "cust_no", 
					visible : false
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
				},
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no", 
					width : "110",
					minWidth : "105",
					style : "aui-center"
				},
				{ 
					headerText : "적요", 
					dataField : "dis_desc_text", 
					width : "280",
					minWidth : "200",
					style : "aui-left"
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "85",
					style : "aui-right"
				},
// 				{ 
// 					headerText : "금액", 
// 					dataField : "doc_amt",
// 					dataType : "numeric",
// 					formatString : "#,##0",
// 					width : "7%",
// 					style : "aui-right"
// 				},
				{ 
					headerText : "처리자", 
					dataField : "reg_mem_name",
					width : "65",
					minWidth : "60",
					style : "aui-center"
				},
				{ 
					headerText : "비고", 
					dataField : "desc_text",
					width : "280",
					minWidth : "200",
					style : "aui-left"
				},
				{
					headerText : "매출전표번호",
					dataField : "sale_inout_doc_no",
					width : "110",
					minWidth : "110",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						if(docNo != "") {
							return docNo.substring(4, 16);
						}
						return "";
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "cust_name" ) {
					var params = {
							inout_doc_no : event.item["inout_doc_no"]
					}
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
					$M.goNextPage('/cust/cust0203p01', $M.toGetParam(params), {popupStatus : popupOption});
				} else if (event.dataField == "sale_inout_doc_no") {
					var params = {
						inout_doc_no : event.item["sale_inout_doc_no"]
					}
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_breg_name", "s_breg_no", "s_inout_doc_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		//조회
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
					"s_sort_key" : "inout_dt desc, inout_doc_no", 
					"s_sort_method" : "desc",
					"s_inout_doc_no" : $M.getValue("s_inout_doc_no"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_breg_name" : $M.getValue("s_breg_name"),
					"s_breg_no" : $M.getValue("s_breg_no"),
					"s_inout_type_cd" : $M.getValue("s_inout_type_cd"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"page" : page,
					"rows" : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		} 
		// 조회
		function goSearch() { 
// 			if($M.getValue("s_cust_name") == "" && $M.getValue("s_breg_name") == "" && $M.getValue("s_breg_no") == "" && $M.getValue("s_hp_no") == "") {
// 				alert("고객명 or 업체명 or 사업자번호 or 휴대폰을 입력해주세요.");
// 				return false;
// 			}
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
		
		function goNew() {
			$M.goNextPage("/cust/cust020301");
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
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="120px">
								<col width="80px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>발행일</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" required="required" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" required="required" value="${searchDtMap.s_end_dt}">
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
									<th>전표번호</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_inout_doc_no" name="s_inout_doc_no">
										</div>
									</td>								
									<th>고객명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
										</div>
									</td>	
									<th>업체명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_breg_name" name="s_breg_name">
										</div>
									</td>	
									<th>사업자번호</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_breg_no" name="s_breg_no" placeholder="-없이 숫자만">
										</div>
									</td>
									<th>구분</th>
									<td>
										<select class="form-control" id="s_inout_type_cd" name="s_inout_type_cd" >
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['INOUT_TYPE']}">
							 				<c:if test="${item.code_name eq '입금' || item.code_name eq '출금'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
											</c:forEach>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>전표발행내역</h4>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

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