<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > null > null
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
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				usePaging : false,
				showRowCheckColumn : true,
				editable : false,
				nullsLastOnSorting : true, // 정렬 시 null이나 ""값 마지막으로 보냄
				sortableByFormatValue : true, // 정렬 시 데이터 기반이 아닌 그리드에 출력된 값을 기반으로 정렬을 실행
			};
			var columnLayout = [
				{
					headerText : "발행일", 
					dataField : "inout_dt",
					width : "70",
					minWidth : "70",
					headerStyle : "aui-fold",
					dataType : "date",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					style : "aui-center aui-popup",
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{ 
					headerText : "전표구분", 
					dataField : "inout_doc_type_cd", 
					width : "70",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var inoutName = "";
						switch(value) {
						case "05" : 
							if(item["preorder_yn"] == "Y") {
								inoutName = "선주문";
							} else {
								inoutName = "수주";
							}
							break;
						case "07" : inoutName = "정비"; break;
						case "11" : inoutName = "렌탈"; break;
						}
						return inoutName;
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "150",
					minWidth : "130",
					style : "aui-center",
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					headerStyle : "aui-fold",
					width : "140",
					minWidth : "130",
					style : "aui-center",
				},
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no", 
					headerStyle : "aui-fold",
					width : "110",
					minWidth : "105",
					style : "aui-center",
				},
				{ 
					headerText : "적요", 
					dataField : "dis_desc_text", 
					width : "350",
					minWidth : "200",
					style : "aui-left",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "80",
					style : "aui-right",
				},
				{ 
					headerText : "처리구분", 
					dataField : "vat_treat_cd", 
					headerStyle : "aui-fold",
					width : "80",
					minWidth : "70",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var vatTreatName = "";
						if(value == "Y") {
							vatTreatName = "세금";
						} else if (value == "R") {
							vatTreatName = "보류";
						} else if (value == "S") {
							vatTreatName = "합산";
						} else if (value == "F" && item.taxbill_send_cd == "5") {
							vatTreatName = "수정";
						} else if (value == "C") {
							vatTreatName = "카드매출";
						} else if (value == "A") {
							vatTreatName = "현금영수증";
						} else if (value == "N") {
							vatTreatName = "무증빙";
						}
						return vatTreatName;
					}
				},
				{ 
					headerText : "처리자", 
					dataField : "mem_name", 
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					dataField : "mem_no", 
					visible : false
				},
				{ 
					headerText : "계산서발행일", 
					dataField : "taxbill_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "70",
					style : "aui-center",
				},
				{ 
					headerText : "미수금", 
					dataField : "misu_amt",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right",
				},
				// 23.05.02 [정윤수] Q&A 17407 컬럼 추가
				{ 
					headerText : "출고상태", 
					dataField : "out_status",  
					width : "80",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(item.inout_doc_type_cd == "05" && item.send_out_center_cnt > 0){
							if (item.no_out_cnt == 0) {
								return "출고완료";
							} else {
								return "미출고";
							}
						} else{
							return "";
						}
					},
				},
				{ 
					headerText : "발송센터 수", 
					dataField : "send_out_center_cnt",  
					width : "80",
					minWidth : "80",
					style : "aui-center aui-popup",
					dataType : "numeric",
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return value;
						}
					},
				},
				{ 
					dataField : "no_out_cnt",  //미발송센터 수
					visible : false,
				},
				{ 
					headerText : "배송상태", 
					dataField : "cust_ord_status_name",  
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{
					dataField : "cust_ord_status_cd",
					visible : false,
				},
				{
					dataField : "part_return_result_cd",
					visible : false,
				},
				{ 
					headerText : "클레임상태", 
					dataField : "part_return_result_name",  
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ){
						var returnStatus = "";
						switch(item.part_return_result_cd) {
							case "01" :	returnStatus = "반품신청"; break;
							case "02" : returnStatus = "반품승인"; break;
							case "03" : returnStatus = "반품반려"; break;
						}
						return returnStatus;
					},
				},
				{
					headerText : "고객앱",
					dataField : "cust_app_yn",
					headerStyle : "aui-fold",
					style : "aui-center",
					width : "50",
					minWidth : "50"
				},
				{ 
					headerText : "비고", 
					dataField : "dis_remark", 
					headerStyle : "aui-fold",
					style : "aui-left",
					width : "200",
					minWidth : "195"
				},
				{ 
					dataField : "preorder_yn", 
					visible : false
				},
				{ 
					dataField : "temp_yn", 
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "inout_doc_no" ) {
					var params = {
							"inout_doc_no" : event.item["inout_doc_no"],
							"temp_yn" : event.item["temp_yn"]
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
				} else if(event.dataField == "send_out_center_cnt" && event.item.inout_doc_type_cd == "05"){ // 23.05.02 [정윤수] Q&A 17407 부품발송상세 팝업 추가
					var params = {
						"inout_doc_no" : event.item["inout_doc_no"]
					};
					var popupOption = "";
					$M.goNextPage('/cust/cust0202p07', $M.toGetParam(params), {popupStatus : popupOption});
				} else if(event.dataField == "part_return_result_name" && event.item.part_return_result_cd != ""){
					var params = {
						"inout_doc_no" : event.item["inout_doc_no"]
					};
					var popupOption = "";
					$M.goNextPage('/cust/cust0202p08', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}

			// 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_inout_doc_no", "s_cust_name", "s_breg_name", "s_breg_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
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
		
		//조회
		function fnSearch(successFunc) { 
			isLoading = true;
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return false;
			}; 
			var param = {
					"s_sort_key" : "inout_dt desc, inout_doc_no", 
					"s_sort_method" : "desc",
					"s_inout_doc_no" : $M.getValue("s_inout_doc_no"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_breg_name" : $M.getValue("s_breg_name"),
					"s_breg_no" : $M.getValue("s_breg_no"),
					"s_inout_doc_type_cd" : $M.getValue("s_inout_doc_type_cd"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_out_yn" : $M.getValue("s_out_yn"),
					"s_cust_ord_status_cd" : $M.getValue("s_cust_ord_status_cd"),
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
		
		function goNew() {
			$M.goNextPage('/cust/cust020201');
		}
		
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "매출처리", exportProps);
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
								<col width="55px">
								<col width="260px">								
								<col width="55px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="40px">
								<col width="80px">
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>발행일</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
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
										<input type="text" class="form-control" id="s_inout_doc_no" name="s_inout_doc_no">
									</td>
									<th>고객명</th>
									<td>
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</td>
									<th>업체명</th>
									<td>
										<input type="text" class="form-control" id="s_breg_name" name="s_breg_name">
									</td>
									<th>사업자번호</th>
									<td>
										<input type="text" class="form-control" id="s_breg_no" name="s_breg_no" placeholder="-없이 숫자만">
									</td>
									<th>구분</th>
									<td>
										<select class="form-control" id="s_inout_doc_type_cd" name="s_inout_doc_type_cd" >
											<option value="">- 전체 -</option>
											<option value="05">수주</option>
											<option value="07">정비</option>
											<option value="11">렌탈</option>
											<option value="Y">선주문</option>
										</select>
									</td>
									<th>출고상태</th>
									<td>
										<select class="form-control" id="s_out_yn" name="s_out_yn" >
											<option value="">- 전체 -</option>
											<option value="N">미출고</option>
											<option value="Y">출고완료</option>
										</select>
									</td>
									<th>배송상태</th>
									<td>
										<select class="form-control" id="s_cust_ord_status_cd" name="s_cust_ord_status_cd" >
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['CUST_ORD_STATUS']}" var="item">
												<c:if test="${item.code_value ne 'CART' and item.code_value ne 'ORD_OK'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
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
					<div class="title-wrap mt10">
						<h4>매출처리내역</h4>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>	
					</div>				
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>