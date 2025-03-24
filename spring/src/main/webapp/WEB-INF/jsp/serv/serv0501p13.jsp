<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 개인별 랭킹
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var rankName = ["최종 순이익", "전화응대", "부품판매순이익", "렌탈순이익", "유무상정비시간"];
		var unitType = ["원", "건", "원", "원", "Hr"];
		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});

		// 순이익 랭킹
		function goFirstRank() {
			$M.setValue("rank_type", "tot_profit");
			goSearch();
		}

		// 전화응대 랭킹
		function goSecondRank() {
			$M.setValue("rank_type", "tot_call_cnt");
			goSearch();
		}

		// 부품판매순이익 랭킹
		function goThirdRank() {
			$M.setValue("rank_type", "part_profit_amt");
			goSearch();
		}

		// 렌탈순이익 랭킹
		function goFourthRank() {
			$M.setValue("rank_type", "rental_profit_amt");
			goSearch();
		}

		// 유무상 정비시간 랭킹
		function goFifthRank() {
			$M.setValue("rank_type", "tot_job_hour");
			goSearch();
		}

		// 조회
		function goSearch() {
			var param = {
				"rank_type": $M.getValue("rank_type"),
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_inout_yn": $M.getValue("s_inout_yn")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET', loader: false},
					function (result) {
						if (result.success) {
							fnDataSetting(result.firstList);
							AUIGrid.setGridData(auiGrid, result.list);
							$("#rank_type_name").text(result.rankTypeName);
						}
					}
			);
		}

		// 랭킹 데이터 셋팅
		function fnDataSetting(data) {
			for (var i = 0; i < data.length; i++) {
				$("#rank_name_" + i).text(rankName[i]);
				$("#unit_type_" + i).text(unitType[i]);

				var orgName = data[i] == null ? "-" : data[i].org_name;
				var memName = data[i] == null ? "-" : data[i].mem_name;
				var finalResult = data[i] == null ? "-" : $M.numberFormat($M.toNum(data[i].final_result));
				var profileImg = data[i] == null ? "/file/0" : "/file/" + data[i].pic_file_seq;

				console.log("org_name_" + i + " : " + orgName + " || mem_name_" + i + " : " + memName + " || final_result_" + i + " : " + finalResult + " || profile_img_" + i + " : " + profileImg);

				$("#org_name_" + i).text(orgName);
				$("#mem_name_" + i).text(memName);
				$("#final_result_" + i).text(finalResult);
				$("#profile_img_" + i).attr("src", profileImg);
			}
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
				showFooter: true,
				footerPosition : "top"
			};

			var columnLayout = [
				{
					headerText: "랭킹",
					dataField: "rank",
					width: "50",
					minWidth: "40",
					style: "aui-center"
				},
				{
					headerText: "부서",
					dataField: "org_name",
					width: "80",
					minWidth: "70",
					style: "aui-center"
				},
				{
					headerText: "사원",
					dataField: "mem_name",
					width: "60",
					minWidth: "50",
					style: "aui-center"
				},
				{
					headerText: "전화",
					children: [
						{
							headerText: "전화상담일지",
							dataField: "as_call_cnt",
							dataType: "numeric",
							formatString: "#,##0",
							width: "80",
							minWidth: "70",
							style: "aui-center",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							}
						},
						{
							headerText: "안건상담",
							dataField: "consult_cnt",
							dataType: "numeric",
							formatString: "#,##0",
							width: "70",
							minWidth: "60",
							style: "aui-center",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							}
						}
					]
				},
				{
					headerText: "유무상<br>정비시간",
					dataField: "tot_job_hour",
					dataType: "numeric",
					width: "70",
					minWidth: "60",
					style: "aui-center",
					formatString: "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					}
				},
				{
					headerText: "유상 순이익",
					dataField: "cost_profit_amt",
					dataType: "numeric",
					width: "100",
					minWidth: "90",
					style: "aui-right",
					formatString: "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					}
				},
				{
					headerText: "무상 순이익",
					dataField: "free_profit_amt",
					dataType: "numeric",
					formatString: "#,##0",
					width: "100",
					minWidth: "90",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
					headerText: "부품판매 순이익",
					dataField: "part_profit_amt",
					dataType: "numeric",
					width: "100",
					minWidth: "90",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
					headerText: "중고손익",
					dataField: "machine_used_profit_amt",
					dataType: "numeric",
					width: "100",
					minWidth: "90",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
					headerText: "렌탈 순이익",
					dataField: "rental_profit_amt",
					dataType: "numeric",
					formatString: "#,##0",
					width: "100",
					minWidth: "90",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
					headerText: "최종 순이익",
					dataField: "tot_profit",
					dataType: "numeric",
					formatString: "#,##0",
					width: "100",
					minWidth: "90",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					}
				}
			];

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText: "평균",
					colSpan : 3,
					positionField: "rank"
				},
				{
					dataField: "as_call_cnt",
					positionField: "as_call_cnt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "consult_cnt",
					positionField: "consult_cnt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "tot_job_hour",
					positionField: "tot_job_hour",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_profit_amt",
					positionField: "cost_profit_amt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_profit_amt",
					positionField: "free_profit_amt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "part_profit_amt",
					positionField: "part_profit_amt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "machine_used_profit_amt",
					positionField: "machine_used_profit_amt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				},
				{
					dataField: "tot_profit",
					positionField: "tot_profit",
					formatString: "#,##0.0",
					operation: "AVG",
					style: "aui-right aui-footer",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);

			$("#auiGrid").resize();
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
	<input type="hidden" id="rank_type" name="rank_type">
	<input type="hidden" id="s_year_mon" name="s_year_mon" value="${inputParam.s_year_mon}">
	<input type="hidden" id="s_start_dt" name="s_start_dt" value="${inputParam.s_start_dt}">
	<input type="hidden" id="s_end_dt" name="s_end_dt" value="${inputParam.s_end_dt}">
	<input type="hidden" id="s_inout_yn" name="s_inout_yn" value="${inputParam.s_inout_yn}">

	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-rank">
				<h4>
					<c:choose>
						<c:when test="${inputParam.s_start_year_mon ne inputParam.s_end_year_mon}">
							${fn:substring(inputParam.s_start_year_mon,0,4) }년 ${fn:substring(inputParam.s_start_year_mon,4,6)}월
							~
							${fn:substring(inputParam.s_end_year_mon,0,4) }년 ${fn:substring(inputParam.s_end_year_mon,4,6)}월
						</c:when>
						<c:otherwise>
							${fn:substring(inputParam.s_end_year_mon,0,4) }년 ${fn:substring(inputParam.s_end_year_mon,4,6)}월
						</c:otherwise>
					</c:choose>
					랭킹 (${inputParam.inout_name})
				</h4>
			</div>
			<div class="rank-items">
				<c:forEach var="i" begin="0" end="4">
					<div class="rank-item">
						<div class="rank-field" id="rank_name_${i}">
						</div>
						<div class="rank-photo">
							<div>
								<img src="/static/img/icon-rank.png" alt="1등">
							</div>
							<div class="photo">
								<img id="profile_img_${i}" src="" alt="프로필 사진"/>
							</div>
						</div>
						<div class="rank-info">
							<span id="org_name_${i}"></span>
							<span id="mem_name_${i}"></span>
						</div>
						<div class="rank-figure">
							<span id="final_result_${i}"></span>
							<span class="font-sm" id="unit_type_${i}"></span>
						</div>
					</div>
				</c:forEach>
			</div>
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap mt20">
					<div class="left">
						<h4 id="rank_type_name"></h4>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
			<!-- /폼테이블-->
			<div class="btn-group mt10">
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