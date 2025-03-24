<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 해외거래선관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();

			goSearch();
		});
		
		// 페이지 이동
		function goNew() {
			$M.goNextPage("/sale/sale030201");
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "해외거래선관리");
		}
		
		function goSearch() {
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid,result.list);
					}
				}
			);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
				// fixedColumnCount : 6,
				height : 555
			};
			var columnLayout = [
				{ 
					headerText : "거래선", 
					dataField : "maker_name",
					width : "70",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "거래선코드",
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "순번",
					dataField : "seq_no",
					visible : false
				},
				{ 
					headerText : "사업부", 
					dataField : "biz_kor_name",
					width : "90",
					minWidth : "80",
					style : "aui-center",
				},
				{ 
					headerText : "사업부 영문명", 
					dataField : "biz_eng_name",
					width : "250",
					minWidth : "190",
					style : "aui-center aui-popup"
				},
				{
					headerText : "영문명", 
					dataField : "charge_name",
					width : "150",
					minWidth : "140",
					style : "aui-center"
				},
				{
					headerText : "상태코드",
					dataField : "overseas_work_status_cd",
					visible : false
				},
				{ 
					headerText : "담당업무", 
					dataField : "charge_job",
					width : "130",
					minWidth : "120",
					style : "aui-center",
				},
				{ 
					headerText : "근무국가", 
					dataField : "work_country",
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "도시", 
					dataField : "work_city",
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "현업", 
					dataField : "current_job_name",
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "현업코드",
					dataField : "current_job_yn",
					visible : false
				},
				{ 
					headerText : "회사전화", 
					dataField : "tel_no",
					width : "120",
					minWidth : "110",
					style : "aui-center",
				},
				{ 
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "100",
					minWidth : "90",
					style : "aui-center",
				},
				{
					headerText : "E-mail", 
					dataField : "email",
					width : "180",
					minWidth : "170",
					style : "aui-left aui-popup",
				},
				{ 
					headerText : "주소", 
					dataField : "addr",
					width : "180",
					minWidth : "170",
					style : "aui-left"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'biz_eng_name') {
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";

					var param = {
						"maker_cd" : event.item.maker_cd,
						"seq_no" : event.item.seq_no
					};

					$M.goNextPage('/sale/sale0302p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} else if(event.dataField == "email" && event.item.email != "") {
					var param = {
						"to" : event.item.email
					};
					openSendEmailPanel($M.toGetParam(param));
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
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>거래선</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
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
						<h4>거래선역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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