<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 차주명조회
-- 작성자 : 박예진
-- 최초 작성일 : 2021-03-22 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script type="text/javascript">

	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
		var custName = "${inputParam.s_cust_name}";
		
		if (custName != "") {
			$M.setValue("s_cust_name", custName);
			goSearch();
		}
	});

	//조회
	function goSearch() { 
		var param = {
				"s_cust_name" : $M.getValue("s_cust_name"),
				"s_breg_name" : $M.getValue("s_breg_name"),
				"s_body_no" : $M.getValue("s_body_no"),
				"s_hp_no" : $M.getValue("s_hp_no"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
		};
		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
				};
			}
		);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_cust_name", "s_breg_name", "s_body_no", "s_hp_no"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch(document.main_form);
			};
		});
	}
	
	function createAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "body_no",
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			headerHeight : 40
		};
		var columnLayout = [
			{ 
				headerText : "차주명", 
				dataField : "cust_name", 
				width : "120", 
				minWidth : "120", 
				style : "aui-center"
			},
			{ 
				headerText : "휴대폰", 
				dataField : "hp_no", 
				width : "120", 
				minWidth : "120", 
				style : "aui-center",
			},
			{ 
				headerText : "주소", 
				dataField : "addr", 
				width : "320", 
				minWidth : "320", 
				style : "aui-left",
			},
			{ 
				headerText : "개인정보<br>수집동의", 
				dataField : "personal_yn", 
				width : "55", 
				minWidth : "55", 
				style : "aui-center"
			},
			{ 
				headerText : "업체명", 
				dataField : "breg_name", 
				width : "140", 
				minWidth : "140", 
				style : "aui-center"
			},
			{ 
				headerText : "장비명", 
				dataField : "machine_name", 
				width : "120", 
				minWidth : "120", 
				style : "aui-left"
			},
			{ 
				headerText : "차대번호", 
				dataField : "body_no", 
				width : "160", 
				minWidth : "160", 
				style : "aui-left"
			},
			{ 
				headerText : "엔진번호", 
				dataField : "engine_no_1",
				width : "100", 
				minWidth : "100",  
				style : "aui-left"
			},
			{ 
				headerText : "판매일자", 
				dataField : "sale_dt",
				width : "75", 
				minWidth : "75", 
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center"
			},
			{
				dataField : "cust_no",
				visible : false
			}
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
// 		AUIGrid.bind(auiGrid, "cellClick", function(event) {
// 			if("${inputParam.part_sale_yn}" != "Y") {
// 				// Row행 클릭 시 반영
// 				try{
// 					opener.${inputParam.parent_js_name}(event.item);
// 					window.close();	
// 				} catch(e) {
// 					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
// 				}
// 			}
// 		});	
		$("#auiGrid").resize();
	}
	
	//모델조회
// 	function setModelInfo(row) {
// 		$M.setValue("s_machine_name", row.machine_name);
// 	}
	
	//팝업 끄기
	function fnClose() {
		window.close(); 
	}

</script>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 (문자발송) -->
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
						<col width="120px">
						<col width="60px">
						<col width="120px">
						<col width="60px">
						<col width="120px">
						<col width="60px">
						<col width="120px">
						<col width="120px">
					</colgroup>
					<tbody>
						<tr>
							<th>차주명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_cust_name" name="s_cust_name" class="form-control" placeholder="">
								</div>
							</td>
							<th>업체명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_breg_name" name="s_breg_name" class="form-control">
								</div>
							</td>
							<th>차대번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_body_no" name="s_body_no" class="form-control">
								</div>
							</td>
							<th>휴대폰</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							<th class="text-right">		
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								</div>
								</c:if>										
							</th>
							<td class="text-left"><button type="button" class="btn btn-important" style="width: 60px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			
			<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
			
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
    </form>
<!-- /팝업 (문자발송) -->
	
</body>
</html>