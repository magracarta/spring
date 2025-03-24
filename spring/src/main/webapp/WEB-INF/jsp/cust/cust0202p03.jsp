<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > null > 정비참조
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		//조회
		function fnSearch(successFunc) { 
			isLoading = true;
			var param = {
					"s_sort_key" : "job_report_no", 
					"s_sort_method" : "asc",
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_job_status_cd" : $M.getValue("s_job_status_cd"),
					"s_refer_yn" : "${inputParam.s_refer_yn}",
					"s_body_no" : $M.getValue("s_body_no"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_job_yn" : "${inputParam.s_job_yn}",
					"page" : page,
					"rows" : $M.getValue("s_rows")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						isLoading = false;
						if(result.success) {
							successFunc(result);
						};
					}
				);
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
		
		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			
			if("${inputParam.s_body_no}" != "") {
				$("#s_body_no").attr("disabled", true);
			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "job_report_no",
				// No. 제거
				showRowNumColumn: true,
				rowIdTrustMode : true,
				editable : false,
				showFooter : false,
				footerPosition : "top",
			};
			

			if("${inputParam.s_body_no}" != "") {
				gridPros.showFooter = true;
			}
			
			var columnLayout = [
				{
					headerText : "상담일자", 
					dataField : "consult_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "95",
					minWidth : "95",
					style : "aui-center"
				},
				{ 
					headerText : "방문일자", 
					dataField : "visit_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "95",
					minWidth : "95",
					style : "aui-center"
				},
				{ 
					headerText : "차주명", 
					dataField : "cust_name", 
					width : "150",
					style : "aui-center",
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "160",
					style : "aui-center",
				},
				{ 
					headerText : "접수자", 
					dataField : "mem_name", 
					width : "70",
					style : "aui-center",
				},
				{ 
					dataField : "mem_no", 
					visible : false
				},
				{ 
					headerText : "정비자", 
					dataField : "eng_mem_name", 
					width : "70",
					style : "aui-cetner",
				},
				{ 
					dataField : "eng_mem_no", 
					visible : false
				},
				{ 
					dataField : "job_report_no", 
					visible : false
				},
				{ 
					dataField : "cust_no", 
					visible : false
				},
				{ 
					headerText : "완료일자", 
					dataField : "complete_date", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "95",
					style : "aui-cetner",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					style : "aui-right",
				},
				{
					headerText : "상태",
					dataField : "job_status_name",
					width : "80",
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "complete_date",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if("${inputParam.s_job_yn}" == "Y") {
					var params = {
		                    "s_job_report_no": event.item["job_report_no"]
		                };
		            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
		            $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
				} else {
					// Row행 클릭 시 반영
					try{
						opener.${inputParam.parent_js_name}(event.item);
						window.close();	
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				}
				
			});	
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_body_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function fnClose() {
			window.close();
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>정비현황</h4>
			</div>
<!-- 검색영역 -->					
			<div class="search-wrap mt5">				
				<table class="table table-fixed">
					<colgroup>
						<c:choose>
							<c:when test="${inputParam.s_refer_yn eq 'Y' }">
								<col width="82px">
							</c:when>
							<c:otherwise>
								<col width="65px">							
							</c:otherwise>
						</c:choose>
						<col width="260px">
						<col width="55px">
						<col width="100px">
						<col width="65px">
						<col width="100px">
						<col width="65px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>완료<c:if test="${inputParam.s_refer_yn eq 'Y'}">/작업</c:if>일자</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_start_dt}">
										</div>
									</div>
									<div class="col-auto text-center">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_end_dt}">
										</div>
									</div>
								</div>
							</td>
							<th>차주명</th>
							<td>
								<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
							</td>
							<th>차대번호</th>
							<td>
								<input type="text" class="form-control" id="s_body_no" name="s_body_no" value="${inputParam.s_body_no}">
							</td>
							
								<c:choose>
									<c:when test="${inputParam.s_refer_yn eq 'Y'}">
									<th>진행구분
									</th>
										<td>
										<input class="form-control" type="text" value="${codeMap['JOB_STATUS'][1].code_name} 이상" readonly="readonly">
										</td>
									</c:when>
									<c:when test="${inputParam.s_job_yn eq 'Y'}">
										<th>진행구분</th>
										<td>
										<select class="form-control" id="s_job_status_cd" name="s_job_status_cd">
											<option value="" selected="selected">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['JOB_STATUS']}">
							 					<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
										</td>
									</c:when>
									<c:otherwise>
										<th>진행구분</th>
										<td>
										<select class="form-control" id="s_job_status_cd" name="s_job_status_cd" disabled="disabled">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['JOB_STATUS']}">
							 					<option value="${item.code_value}" ${inputParam.s_job_status_cd eq item.code_value ? 'selected' : ''}>${item.code_name}</option>
											</c:forEach>
										</select>
										</td>
									</c:otherwise>
								</c:choose>
							
							<td>	
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>		
						</tr>						
					</tbody>
				</table>					
			</div>
<!-- /검색영역 -->
<!-- 폼테이블 -->					
			<div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt10">
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>