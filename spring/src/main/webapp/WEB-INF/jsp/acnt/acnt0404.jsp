<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 월정산서관리-위탁판매점 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-10-05 17:43:39
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
			fnInit();
		});

		function fnInit() {
			// 로그인 회원이 대리점일경우 해당대리점 세팅, 아닐경우 대리점 선택후 조회
			var secureOrgCode = $M.getValue("secure_org_code");
			var secureOrgCodeStr = $M.getValue("secure_org_code").substr(0,1);
			console.log(secureOrgCodeStr);

			if ("${page.fnc.F00840_001}" == "Y") {
				$M.setValue("s_org_code", "0");
				$("#s_org_code").attr("disabled", false);
			} else {
				$M.setValue("s_org_code", secureOrgCode);
				$("#s_org_code").attr("disabled", true);
			}
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					// 고정칼럼 카운트 지정
					useGroupingPanel : false,
					enableFilter :true,
					// No. 제거
					showRowNumColumn: true,
					editable : false,
			};
			var columnLayout = [
				{
					dataField : "agency_type_ca",
					visible : false,
				},
				{
					dataField : "agency_pay_no",
					visible : false
				},
				{
					dataField : "agency_pay_status_cd",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "정산년월",
					dataField : "pay_dt",
					width : "8%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "전체미수",
					dataField : "all_misu",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미확보미수",
					dataField : "misu_unsecure",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미수금합계",
					dataField : "misu_sum",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "지급예정",
					dataField : "schedule_money",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미확정수수료",
					dataField : "pending_money",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "채권사항",
					children : [
						{
							headerText : "계",
							dataField : "total_bond",
// 							width : "10%",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							headerText : "보증금",
							dataField : "bjngmoney",
// 							width : "10%",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							headerText : "담보금",
							dataField : "dambomoney",
// 							width : "10%",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}
					]
				},
				{
					headerText : "일자",
					dataField : "pay_dt",
					dataType : "date",
					width : "8%",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 정산년월 클릭시 월정산서관리-대리점 팝업 호출
				if(event.dataField == "pay_dt") {
					var params = {
							pay_dt : event.item.pay_dt,
							org_code : event.item.org_code,
							agency_pay_no : event.item.agency_pay_no
					}
					var popupOption = "";
					$M.goNextPage('/acnt/acnt0402p03', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}

		// 조회
		function goSearch() {
			console.log("s_org_code : ", $M.getValue("s_org_code"));

			if ($M.getValue("s_org_code") == "" || $M.getValue("s_org_code") == "0") {
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// alert("대리점을 선택해 주세요.");
				alert("위탁판매점을 선택해 주세요.");
				return;
			}

			var param = {
					s_org_code : $M.getValue("s_org_code"),
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

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
			// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
		  	// fnExportExcel(auiGrid, "월정산서관리-대리점", exportProps);
		  	fnExportExcel(auiGrid, "월정산서관리-위탁판매점", exportProps);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="secure_org_code" name="secure_org_code" value="${secure_org_code}">
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
								<col width="60px">
								<col width="140px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<th>대리점</th>--%>
									<th>위탁판매점</th>
									<td>
										<select class="form-control" id="s_org_code" name="s_org_code" disabled>
											<option value="0">- 선택 -</option>
											<c:forEach var="item" items="${agencyList}">
											<option value="${item.code_value}">${item.code_name}</option>
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
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>
					</div>
				</div>
			</div>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
