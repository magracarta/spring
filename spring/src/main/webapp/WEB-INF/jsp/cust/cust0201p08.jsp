<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > 수동매칭
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-08-27 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;

	$(document).ready(function() {
		createAUIGrid(); // 메인 그리드
		fnInit();
	});
	function fnInit() {
		
	}
	// 대신화물 수동매칭 그리드 생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			showStateColumn : false,
			editable : false,
		};
		var columnLayout = [
			{ 
				headerText : "참조번호", 
				dataField : "bill_no", 
				width : "120", 
				style : "aui-center",
			},
			{ 
				headerText : "등록일시", 
				dataField : "input_day", 
				width : "120", 
				style : "aui-center",
			},
			{ 
				headerText : "도착지 영업소", 
				dataField : "arrivae_agency", 
				width : "160", 
				style : "aui-center",
			},
			{ 
				headerText : "도착지 주소", 
				dataField : "arrive_address", 
				width : "220", 
				style : "aui-center",
			},
			{ 
				headerText : "도착일시", 
				dataField : "exp_date", 
				width : "120", 
				style : "aui-center",
			},
			{ 
				headerText : "수취인", 
				dataField : "arrive_man", 
				width : "80", 
				style : "aui-center",
			},
			{ 
				headerText : "수취인 연락처", 
				dataField : "arrive_man_tel", 
				width : "100", 
				style : "aui-center",
			},
			{ 
				headerText : "상품구분", 
				dataField : "goods", 
				width : "80", 
				style : "aui-center",
			},
			{ 
				headerText : "포장단위", 
				dataField : "po_jang", 
				width : "80", 
				style : "aui-center",
			},
			{ 
				headerText : "수량", 
				dataField : "qty", 
				width : "50", 
				style : "aui-center",
			},
			{ 
				headerText : "지급구분", 
				dataField : "pay_way", 
				width : "60", 
				style : "aui-center",
			},
			// { 
			// 	headerText : "송장번호", 
			// 	dataField : "", 
			// 	width : "80", 
			// 	style : "aui-center",
			// },
			{ 
				headerText : "배송료", 
				dataField : "e_pay", 
				width : "80", 
				style : "aui-center",
			},
			{ 
				headerText : "부가세", 
				dataField : "tax_pay", 
				width : "80", 
				style : "aui-center",
			},
			{ 
				headerText : "총금액", 
				dataField : "total_pay", 
				width : "80", 
				style : "aui-center",
			},
			{ 
				headerText : "메모", 
				dataField : "memo", 
				style : "aui-center",
			},
			{ 
				headerText : "상태", 
				dataField : "status", 
				width : "80", 
				style : "aui-center",
			},
		];
		
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		$("#total_cnt").html(${total_cnt});
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			try {
				opener.${inputParam.parent_js_name}(event.item);
				window.close();
			} catch(e) {
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
		});
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_arrive_man", "s_arrive_man_tel"];
		$.each(field, function () {
			if (fieldObj.name == this) {
				goSearch();
			}
		});
	}
	
	// 조회
	function goSearch() {
		var param = {
				s_search_yn : "Y",
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_arrive_man_tel : $M.getValue("s_arrive_man_tel"), // 수취인연락처
				s_arrive_man : $M.getValue("s_arrive_man") // 수취인
			};
			
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);			
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
<!-- 폼테이블 -->					
			<div>					
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="250px">
							<col width="50px">
							<col width="120px">
							<col width="100px">
							<col width="120px">
						</colgroup>
						<tbody>
							<tr>
								<th>등록일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" value="${inputParam.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" value="${inputParam.s_end_dt}">
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
								<th>수취인</th>
								<td>
									<input type="text" class="form-control" id="s_arrive_man" name="s_arrive_man">
								</td>
								<th>수취인연락처</th>
								<td>
									<input type="text" class="form-control" id="s_arrive_man_tel" name="s_arrive_man_tel">
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 55px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
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