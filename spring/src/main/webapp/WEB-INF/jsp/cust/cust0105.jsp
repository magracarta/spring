<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 사업자관리/등록 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-01-23 11:36:05
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
			// 사업자목록 그리드 생성
			createAUIGrid();
		});
		
		// 조회
		function goSearch() { 
			if( $M.getValue('s_breg_name') == '' && $M.getValue('s_breg_rep_name') == '' && $M.getValue('s_breg_no') == '') {
				alert('[업체명, 고객명, 사업자번호] 중 하나는 필수입니다.');
				return;
			}
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
		
		// 사업자 목록 조회
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
				"s_breg_name" 		: $M.getValue("s_breg_name"),
				"s_breg_rep_name" 	: $M.getValue("s_breg_rep_name"),
				"s_breg_no" 		: $M.getValue("s_breg_no"),
				"s_breg_type_cd" 	: $M.getValue("s_breg_type_cd"),
				"s_use_yn" 			: $M.getValue("s_use_yn"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"page" : page,
				"rows" : $M.getValue("s_rows")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
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
			if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
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
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "사업자관리/등록", "");
		}
		
		//사업자정보등록 페이지 이동
		function goNew() {
			$M.goNextPage("/cust/cust010501");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "breg_seq",
				showRowNumColumn : true,
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				rowNumColumnWidth : 80,
				fillColumnSizeMode : false,
				height : 650
			};
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "사업자번호", 
					dataField : "breg_no",
                    width: "130",
                    minWidth: "130",
					style : "aui-center"
				},
				{
					headerText : "업체명", 
					dataField : "breg_name", 
                    width: "200",
                    minWidth: "200",
					style : "aui-center aui-popup",
				},
				{ 
					headerText : "대표자", 
					dataField : "breg_rep_name", 
                    width: "110",
                    minWidth: "110",
					style : "aui-center",
				},
				{ 
					headerText : "업태", 
					dataField : "breg_cor_type", 
                    width: "150",
                    minWidth: "150",
					style : "aui-center",
				},
				{ 
					headerText : "업종", 
					dataField : "breg_cor_part", 
                    width: "220",
                    minWidth: "220",
					style : "aui-center",
				},
				{ 
					headerText : "사업자구분", 
					dataField : "breg_type_name", 
                    width: "90",
                    minWidth: "90",
					style : "aui-center",
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
                    width: "70",
                    minWidth: "70",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return item["use_yn"] == "Y" ? "사용" : "사용안함";
					}
				},
				{ 
					headerText : "등록자", 
					dataField : "reg_name", 
                    width: "90",
                    minWidth: "90",
					style : "aui-center",
				},
				{
					headerText : "등록일시", 
					dataField : "reg_date", 
					dataType : "date",	
                    width: "160",
                    minWidth: "160",
					style : "aui-center",
					formatString : "yy-mm-dd HH:MM:ss",
				}	
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 클릭한 셀 데이터 받아 해당 사업자정보 상세페이지 팝업호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "breg_name") {
					var param = {
						breg_seq : event.item["breg_seq"]
					};
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1430, height=500, left=0, top=0";
					$M.goNextPage("/cust/cust0105p01", $M.toGetParam(param), {popupStatus : popupOption});
				};
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_breg_name", "s_breg_rep_name", "s_breg_rep_name", "s_breg_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
	
	</script>
</head>
<body>
	<!-- contents 전체 영역 -->
	<div class="content-wrap" style="height: 850px;">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<!-- <h2>사업자관리/등록</h2> -->
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<!-- 기본 -->					
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="80px">
							<col width="120px">
							<col width="80px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th>업체명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_breg_name" name="s_breg_name" class="form-control">
									</div>
								</td>									
								<th>대표자명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_breg_rep_name" name="s_breg_rep_name" class="form-control">
									</div>
								</td>
								<th>사업자번호</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_breg_no" name="s_breg_no" class="form-control" placeholder="-없이 숫자만">
									</div>
								</td>
								<th>사업자구분</th>
								<td>
									<select class="form-control" id="s_breg_type_cd" name="s_breg_type_cd" style="width: 100%;">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['BREG_TYPE']}">
										<option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>사용여부</th>
								<td>
									<select class="form-control" id="s_use_yn" name="s_use_yn" style="width: 100%;">
										<option value="">- 전체 -</option>
										<option value="Y" selected="selected">사용</option>
										<option value="N">사용안함</option>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
								</td>
							</tr>								
						</tbody>
					</table>
				</div>
				<!-- /기본 -->	
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
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- 그리드 영역 -->		
				<div style="margin-top: 5px;" id="auiGrid"></div>
				<!-- /그리드 영역 -->	
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
</body>
</html>