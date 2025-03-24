<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 사업자정보조회
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
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
			// readonly
			fnSetReadOnly('${inputParam.bregReadOnlyField}'.split(','));
			
			createAUIGrid();
			if ('${inputParam.s_breg_no}' != '' || '${inputParam.s_breg_rep_name}' != ''){
				goSearch();
			}
		});
		
		// 조회
		function goSearch() { 
			if( $M.getValue('s_breg_no') == '' && $M.getValue('s_breg_rep_name') == '') {
				alert('업체명 or 고객명 or 사업자번호를 입력해주세요.');
				return;
			}
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result) {
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		// 엔터키
		function enter(fieldObj) {
			console.log(fieldObj);
			var field = [ "s_breg_rep_name", "s_breg_no" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 조회
		function fnSearch(successFunc) { 
			
			var bregNo = $M.getValue("s_breg_no");
			if (bregNo != "") {
				bregNo = bregNo.replace(/\-/g,"");	
			}
			isLoading = true;
			var param = {
					"s_sort_key" : "breg_name", 
// 					"s_breg_name" : $M.getValue("s_breg_name"),
					"s_breg_rep_name" : $M.getValue("s_breg_rep_name"),
					"s_breg_no" : bregNo,
					"s_breg_type_cd" : $M.getValue("s_breg_type_cd"),
					"page" : page,
					"rows" : $M.getValue("s_rows")
			}
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
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "breg_seq",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false
			};
			var columnLayout = [
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no", 
					width : "10%", 
					style : "aui-center"
				}, 
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "15%", 
					style : "aui-left"
				}, 
				{ 
					headerText : "대표자", 
					dataField : "breg_rep_name", 
					width : "8%", 
					style : "aui-center"
				}, 
				{ 
					headerText : "업태", 
					dataField : "breg_cor_type", 
					width : "18%", 
					style : "aui-center"
				}, 
				{ 
					headerText : "업종", 
					dataField : "breg_cor_part", 
					width : "15%", 
					style : "aui-left",
				}, 
				{ 
					headerText : "사업자구분", 
					dataField : "breg_type_name", 
					style : "aui-center",
				}, 
				// 기획에서 사용여부 삭제(0108)
				/* { 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "8%",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return item['use_yn']=='Y'?'사용':'미사용' 
					}
				},  */
				{ 
					headerText : "등록자", 
					dataField : "reg_mem_name", 
					width : "8%", 
					style : "aui-center",
				}, 
				{ 
					headerText : "등록일시",  
					dataField : "reg_date", 
					dataType : "date",  
					formatString : "yy-mm-dd HH:MM:ss", // 기획문서에 yyyy-mm-dd로 돼있으나, 시분초까지 보여주기로함.(0108)
					style : "aui-center"
				},
				// 사업장주소
				{
					dataField : "biz_post_no", 
					visible : false
				},
				{
					dataField : "biz_addr1",
					visible : false
				},
				{
					dataField : "biz_addr2",
					visible : false
				},
				{
					dataField : "breg_seq",
					visible : false
				},
				{
					dataField : "real_breg_no",
					visible : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});
		}
		
		
		function goNew() {
			var param = {
					"cust_no" : $M.getValue("cust_no"),
					"cust_name" : $M.getValue("cust_name"),
					"parent_js_name" : "${inputParam.parent_js_name}",
					"popup_yn" : "Y"
			}
			$M.goNextPage("/cust/cust010501", $M.toGetParam(param));
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
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="120px">
						<col width="200px">
						<col width="75px">
						<col width="130px">
						<col width="75px">
						<col width="130px">
<%-- 						<col width="75px"> --%>
<%-- 						<col width="100px"> --%>
						<col width="30px">
						<col width="150px">
						<col width="100px">
					</colgroup>
					<tbody>
						<tr>
							<th>업체명 / 사업자번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" placeholder="업체명 / -없이 숫자만" id="s_breg_no" name="s_breg_no" value="${inputParam.s_breg_no}">
								</div>
							</td>
							<th>대표자</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_breg_rep_name" name="s_breg_rep_name" value="${inputParam.s_breg_rep_name}">
								</div>
							</td>
<!-- 							<th>사업자번호</th> -->
<!-- 							<td> -->
<!-- 								<div class="icon-btn-cancel-wrap"> -->
<!-- 									<input type="text" class="form-control" placeholder="-없이 숫자만" id="s_breg_no" name="s_breg_no" datatype="int"> -->
<!-- 								</div>										 -->
<!-- 							</td> -->
							<th>사업자구분</th>
							<td>
								<select class="form-control" id="s_breg_type_cd" name="s_breg_type_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['BREG_TYPE']}" var="item">
									  <option value="${item.code_value}" ${inputParam.s_breg_type_cd == item.code_value ? 'selected="selected"' : ''} >${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th><!-- 사용여부 --></th>
							<td class="text-right">
								<!-- <select class="form-control" id="s_use_yn" name="s_use_yn">
									<option value="Y">사용</option>
									<option value="N">미사용</option>
								</select> -->
						<div class="btn-group mt5">
							<div class="right">
							<button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch()">조회</button>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
							</div>
							</td>
						</tr>
					</tbody>
					
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			<div id="auiGrid" class="mt10" style="width: 100%;height: 600px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>