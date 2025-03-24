<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비운영현황 > 분포현황 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-04-20 13:38:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* 연식대비 가동율 셀 컬러 안내문구용 박스 */
		.color_box {
			border : 1px solid black;
			width: 14px;
			height: 18px;
		}
		/* 연식대비 가동시간이 지나치게 높은 장비 그리드 셀 */
		.yellow-cell {
			background: #fff8eb;
		}
		/* 연식대비 가동시간이 지나치게 낮은 장비 그리드 셀 */
		.blue-cell {
			background: #e1f5ff;
		}
		.yellow-cell > div:not(:empty)
		, .blue-cell > div:not(:empty) {
			text-decoration: underline;
			cursor: pointer;
			text-underline-position: under;
		}
	</style>
	<script type="text/javascript">

		let auiGrid; // 상단 그리드
		let auiGridDist; // 연식대비 가동율 그리드
		let distCols = ${distCols}; // 연식대비 가동율 컬럼 리스트
		const currentYr = new Date().getFullYear(); // 현재날짜
		let mngOrgCd; // 조회조건 관리센터
		let ownOrgCd; // 조회조건 소유센터
		let makerCd; // 연식대비 가동율 조회용 메이커
		let machinePlantSeq; // 연식대비 가동율 조회용 모델번호

		$(document).ready(function() {
			createAUIGrid();
			createAUIGridDist();

			// 메인 그리드 모델명 컬럼 숨김처리
			AUIGrid.hideColumnByDataField(auiGrid, "machine_name");
		});

		// 메인 그리드 조회
		function goSearch(param) {

			mngOrgCd = $M.getValue("s_mng_org_code");
			ownOrgCd = $M.getValue("s_own_org_code");
			param.s_mng_org_code = mngOrgCd;
			param.s_own_org_code = ownOrgCd;

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						if (!param.s_maker_cd) {
							// <전체> 버튼 클릭 시
							AUIGrid.showColumnByDataField(auiGrid, 'maker_name');
							AUIGrid.hideColumnByDataField(auiGrid, 'machine_name');
						} else {
							// 메이커 버튼 클릭 시
							AUIGrid.showColumnByDataField(auiGrid, 'machine_name');
							AUIGrid.hideColumnByDataField(auiGrid, 'maker_name');
						}
					}
				}
			);
		}

		// 메이커별 조회
		function goSearchMaker(makerCd) {
			const param = {
				s_maker_cd : makerCd
			};
			goSearch(param);
		}

		// 상단 메인 그리드생성
		function createAUIGrid() {
			const gridPros = {
				showRowNumColumn: true,
				headerHeight : 75,
			};

			const columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "90",
					style : "aui-popup"
				},
				{
					dataField: "maker_cd",
					visible: false
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "90",
					style : "aui-popup"
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "매출비율",
					dataField : "amt_rate",
					width : "80",
					style : "aui-center",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "총대수",
					dataField : "total_cnt",
					width : "60",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년매출",
					dataField : "total_amt",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년 총<br>수익",
					dataField : "total_profit",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년<br>대당수익",
					dataField : "profit_per",
					width : "100",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년<br>가동율<br>(매출기준)",
					dataField : "util_rate_amt",
					width : "80",
					dataType: "numeric",
					formatString: "#,###",
					style : "aui-center",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "당년<br>가동율<br>(임대일기준)",
					dataField : "util_rate_days",
					width : "80",
					dataType: "numeric",
					formatString: "#,###",
					style : "aui-center",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "당년 월<br>가동시간",
					dataField : "run_time_mon",
					width : "60",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년<br>매출",
					dataField : "last_total_amt",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년<br>총 수익",
					dataField : "last_total_profit",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년<br>대당수익",
					dataField : "last_profit_per",
					width : "100",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년<br>가동율<br>(매출기준)",
					dataField : "last_util_rate_amt",
					width : "80",
					dataType: "numeric",
					style : "aui-center",
					formatString: "#,###",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "전년<br>가동율<br>(임대일기준)",
					dataField : "last_util_rate_days",
					width : "80",
					dataType: "numeric",
					style : "aui-center",
					formatString: "#,###",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "전년 월<br>가동시간",
					dataField : "last_run_time_mon",
					width : "70",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);

			// 메이커/모델명 클릭 시 연식대비 가동율 조회
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// check
                if (this.self.columnData.style !== "aui-popup") {
                    return false;
                }

				makerCd = event.item.maker_cd ? event.item.maker_cd : "";
				machinePlantSeq = event.item.machine_plant_seq ? event.item.machine_plant_seq : ""

				let param = {
					s_maker_cd : makerCd,
					s_machine_plant_seq : machinePlantSeq,
					s_mng_org_code : mngOrgCd,
					s_own_org_code : ownOrgCd,
				};

				$M.goNextPageAjax(this_page + "/search/detail", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success && result.list) {
						AUIGrid.setGridData(auiGridDist, result.list);
					}
				});
			});
		}

		// 연식대비 가동율 그리드 생성
		function createAUIGridDist() {
			const gridPros = {
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
			};

			let columnLayout = [
				{
					headerText : "연식별",
					dataField : "col_name",
					width : "120",
					style : "aui-center"
				},
				{
					dataField : "op_hour",
					visible : false
				}
			];

			// 푸터 레이아웃
			let footerColumnLayout = [
				{
					labelText : "가동시간별",
					positionField : "col_name",
					style : "aui-center"
				}
			];

			distCols.forEach(item => {
				let header = item.year == '10' ? '10년 이상' : item.year;
				const newCol = {
					headerText : header,
					dataField : item.year,
					width : "100",
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						let yrOld = dataField == '10' ? 10 : parseInt(currentYr) - parseInt(dataField); // 경과연식
						const overVal = (yrOld + 1) * 1000; // (경과연식 + 1) * 1000 이상은 노란색으로 표기
						const downVal = (yrOld) * 500; // 경과연식 * 500 이하는 파란색으로 표기

						let comp = item.op_hour;
						if (overVal < comp) {
							return "yellow-cell"; // 연식대비 가동시간이 지나치게 높은 장비
						} else if (downVal > comp) {
							return "blue-cell"; // 연식대비 가동시간이 지나치게 낮은 장비
						} else {
							return "aui-popup"; // 그 외는 흰색 처리
						}
					}
				};
				const sumCol = {
					dataField : item.year,
					positionField : item.year,
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",
				};
				columnLayout.push(newCol);
				footerColumnLayout.push(sumCol);
			});

			auiGridDist = AUIGrid.create("#auiGridDist", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridDist, []);
			AUIGrid.setFooter(auiGridDist, footerColumnLayout);
			AUIGrid.resize(auiGridDist);

			// 셀 클릭 시, 렌탈장비대장 목록 팝업 호출
			AUIGrid.bind(auiGridDist, "cellClick", function(event) {
				// check
                if (event.dataField == "col_name" || !event.value) {
                    return false;
                }

				let param = {
					"parent_page" : this_page, // 부모페이지 flag
					"s_made_dt" : event.dataField, // 연식 (10년이상일 경우 '10')
					"s_op_hour" : event.item.op_hour, // 가동시간
					"s_mng_org_code" : mngOrgCd, // 관리센터
					"s_own_org_code" : ownOrgCd, // 소유센터
					s_maker_cd : makerCd, // 메이커
					s_machine_plant_seq : machinePlantSeq, // 모델번호
				};

				const popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=800, left=0, top=0";
				$M.goNextPage("/rent/rent0201", $M.toGetParam(param), {popupStatus : popupOption});
			});
		}

	</script>
</head>
<body style="background : #fff;">
<form id="main_form" name="main_form">
	<div class="content-box">
		<div class="contents">
			<!-- 검색영역 -->
			<div class="search-wrap mt10">
				<table class="table table-fixed">
					<colgroup>
						<col width="60px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="70px">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th>소유센터</th>
							<td>
								<select class="form-control" name="s_own_org_code">
									<option value="">- 전체 -</option>
									<c:forEach items="${orgCenterList}" var="item">
										<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if>>${item.org_name}</option>
									</c:forEach>
								</select>
							</td>
							<th>관리센터</th>
							<td>
								<select class="form-control" name="s_mng_org_code">
									<option value="">- 전체 -</option>
									<c:forEach items="${orgCenterList}" var="item">
										<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if>>${item.org_name}</option>
									</c:forEach>
								</select>
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch({});">조회</button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색영역 -->
			<!-- 상단 그리드 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<div class="left" style="flex: 3;">
						<button type="button" class="btn btn-primary-gra" onclick="goSearchMaker('')">전체</button>
						<c:forEach items="${rentalMchList}" var="item">
							<button type="button" class="btn btn-primary-gra" onclick="goSearchMaker('${item.maker_cd}')">${item.maker_name}</button>
						</c:forEach>
					</div>
					<span class="text-warning" tooltip>※ 현재 보유중인 렌탈장비를 기준으로 한 정보입니다. 서비스업무평가와 수치가 다를 수 있습니다.</span>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 290px;"></div>
			<!-- /상단 그리드 -->
			<!-- 연식대비 가동율 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<div class="left">
						<h4>연식대비 가동율</h4>
					</div>
					<div class="right" style="flex: 2;">
						<div class="form-row inline-pd" style="float: right;">
							<div class="col-auto">
								<div class="color_box" style="background: #fff8eb;"></div>
							</div>
							<div class="col-auto">
								<span>연식대비 가동시간이 지나치게 높은 장비(년 1,000시간 이상)</span>
							</div>
							<div class="col-auto ml15">
								<div class="color_box" style="background: #e1f5ff;"></div>
							</div>
							<div class="col-auto">
								<span>연식대비 가동시간이 지나치게 낮은 장비(2년차 부터 년 500시간 이하)</span>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div id="auiGridDist" style="margin-top: 5px; height: 345px;"></div>
			<!-- 연식대비 가동율 -->
		</div>
	</div>
</form>	
</body>
</html>