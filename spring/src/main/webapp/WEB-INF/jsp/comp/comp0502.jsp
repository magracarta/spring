<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 장비연관팝업 > 장비연관팝업 > null > 장비대장관리
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
			createAUIGrid();
			
			// 장비명으로 차대번호 조회 
			if("${inputParam.s_machine_name}" != "") {
				$M.setValue("s_machine_name", "${inputParam.s_machine_name}");
				goSearch();
			}
			if("${inputParam.s_hp_no}" != "" && "${inputParam.s_cust_name}" != "") {
				goSearch();
			}
		});	
		
		// 조회
		function goSearch() { 
			if( $M.getValue('s_cust_name') == '' && $M.getValue('s_body_no') == '' && $M.getValue('s_hp_no') == '') {
				alert('[차주명, 차대번호, 연락처] 중 하나는 필수입니다.');
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
			var field = [ "s_cust_name", "s_body_no", "s_hp_no"];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function fnChangeGubun() {
			//goSearch();
		}
		
		// 조회
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
				"s_sort_key" : "body_no", 
				"s_cust_name" : $M.getValue("s_cust_name"),
				"s_body_no" : $M.getValue("s_body_no"),
				"s_hp_no" : $M.getValue("s_hp_no"),
				"s_machine_name" : $M.getValue("s_machine_name"),
				"s_mch_type_cad_c_yn" : $M.getValue("s_mch_type_cad_c_yn"), // 건기
				"s_mch_type_cad_a_yn" : $M.getValue("s_mch_type_cad_a_yn"), // 농기
				"s_isSearchFromGps" : "${inputParam.isSearchFromGps}" == "Y" ? "Y" :"N",
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
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
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				rowNumColumnWidth : 50,
				// rowIdField가 unique 임을 보장
// 				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
// 				wrapSelectionMove : false
			};
			var columnLayout = [
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "13%", 
					style : "aui-left",
				},
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "모델", 
					dataField : "machine_name", 
					width : "13%", 
					style : "aui-left"
				},
				{ 
					headerText : "엔진번호", 
					dataField : "engine_no_1", 
					style : "aui-center",
				},
				{ 
					headerText : "차주명", 
					dataField : "cust_name", 
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "8%", 
					style : "aui-center",
				},
				{
					headerText : "장비계약", 
					dataField : "mch_type_cad", 
					width : "6%", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						console.log(value);
					    return value == "" || value == "D" ? "" : value == "C" ? "건기" : "농기"; 
					},
					style : "aui-center"
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "15%", 
					style : "aui-left"
				},
				{ 
					headerText : "담당센터", 
					dataField : "center_org_name", 
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "판매일자",  
					dataField : "sale_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "판매자",
					dataField : "sale_mem_name",
					width : "8%", 
					style : "aui-center",
				},
				{ 
					dataField : "machine_seq",
					visible : false
				},
				{ 
					dataField : "machine_plant_seq",
					visible : false
				},
				{ 
					dataField : "cust_no",
					visible : false
				},
				{ 
					dataField : "sale_area_code",
					visible : false
				},
				{ 
					dataField : "machine_type_name",
					visible : false
				},
				{ 
					dataField : "machine_sub_type_name",
					visible : false
				},
				{
					dataField : "last_machine_seq",
					visible : false
				},
				{
					dataField : "last_inst_dt",
					visible : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				try{
					if ("${inputParam.isSearchFromGps}" == "Y" && event.item.aui_status_cd == "C") {
						alert("이 장비는 이미 다른 GPS가 장착돼있거나, SA-R장비입니다.");
						return false;
					}
					if ("${inputParam.isSearchFromGps}" == "Y" 
						&& event.item.last_machine_seq == event.item.machine_seq
						&& event.item.last_inst_dt == "${inputParam.s_current_dt}") {
						alert("같은 장비에서 오늘 탈거된 GPS를 오늘 다시 장착할 수 없습니다.");
						return false;
					};
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_machine_name" name="s_machine_name" value=""/>
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
						<col width="60px">
						<col width="100px">
						<col width="60px">
						<col width="130px">
						<col width="60px">
						<col width="130px">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>차주명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_cust_name" name="s_cust_name" value="${inputParam.s_cust_name}" <c:if test="${not empty inputParam.s_cust_name}"> readonly </c:if>>
								</div>
							</td>
							<th>차대번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_body_no" name="s_body_no">
								</div>
							</td>
							<th>연락처</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_hp_no" name="s_hp_no" format="tel" value="${inputParam.s_hp_no}" <c:if test="${not empty inputParam.s_hp_no}"> readonly </c:if> >
								</div>
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch()">조회</button></td>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_mch_type_cad_c_yn" name="s_mch_type_cad_c_yn" value="Y" onclick="javascript:fnChangeGubun()">
									<label class="form-check-label" for="s_mch_type_cad_c_yn">건설기계</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_mch_type_cad_a_yn" name="s_mch_type_cad_a_yn" value="Y" onclick="javascript:fnChangeGubun()">
									<label class="form-check-label" for="s_mch_type_cad_a_yn">농기계</label>
								</div>
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>										
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