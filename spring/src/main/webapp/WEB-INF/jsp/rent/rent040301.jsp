<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비운영현황 > 운영현황 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-04-20 13:24:07
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		let auiGrid; // 상단 그리드
		let auiGridDtl; // 상세결과 그리드
		let hideList; // 펼침 항목
		let mngOrgCd; // 조회조건 관리센터
		let ownOrgCd; // 조회조건 소유센터
		let sStartDt; // 조회조건 시작년월
		let sEndDt; // 조회조건 끝년월
		let sMakerCd;
		let sMachinePlantSeq;

		/* 페이징처리 관련 변수 */
		let page = 1;
		let moreFlag = "N";
		let isLoading = false;
		let isAsync = true;
		
		$(document).ready(function() {
			// "펼침" 버튼 초기화
			$("input:checkbox[id='s_toggle_column']").attr("checked", false);

			createAUIGrid();
			createAUIGridDtl();

			// headerStyle에 aui-fold가 있는 컬럼항목 구하기
			hideList = AUIGrid.getColumnInfoList(auiGridDtl)
					.filter(obj => obj.headerStyle && obj.headerStyle.includes("aui-fold"))
					.map(obj => obj.dataField);
			// 펼침항목 숨김처리
            AUIGrid.hideColumnByDataField(auiGridDtl, hideList);

			// 메인 그리드 모델명 컬럼 숨김처리
			AUIGrid.hideColumnByDataField(auiGrid, "machine_name");
		});

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
					width : "100",
					style : "aui-popup"
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "매출비율",
					dataField : "amt_rate",
					width : "65",
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
					headerText : "기간매출",
					dataField : "total_amt",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "기간 총<br>수익",
					dataField : "total_profit",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "기간<br>대당수익",
					dataField : "profit_per",
					width : "100",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "기간<br>가동율<br>(매출기준)",
					dataField : "util_rate_amt",
					width : "80",
					dataType: "numeric",
					formatString: "#,###",
					style : "aui-center",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "기간<br>가동율<br>(임대일기준)",
					dataField : "util_rate_days",
					width : "80",
					dataType: "numeric",
					formatString: "#,###",
					style : "aui-center",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "기간 월<br>가동시간",
					dataField : "run_time_mon",
					width : "60",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년동기<br>매출",
					dataField : "last_total_amt",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년동기<br>총 수익",
					dataField : "last_total_profit",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년동기<br>대당수익",
					dataField : "last_profit_per",
					width : "100",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "전년동기<br>가동율<br>(매출기준)",
					dataField : "last_util_rate_amt",
					width : "80",
					dataType: "numeric",
					style : "aui-center",
					formatString: "#,###",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "전년동기<br>가동율<br>(임대일기준)",
					dataField : "last_util_rate_days",
					width : "80",
					dataType: "numeric",
					style : "aui-center",
					formatString: "#,###",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "전년동기 월<br>가동시간",
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

			// 메이커/모델명 클릭 시 상세결과 조회
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// check
				if (this.self.columnData.style !== "aui-popup") {
					return false;
				}

				sMakerCd = event.item.maker_cd ? event.item.maker_cd : "";
				sMachinePlantSeq = event.item.machine_plant_seq ? event.item.machine_plant_seq : "";

				// 조회 시 1 페이지로 초기화
				page = 1;
				moreFlag = "N";

				fnSearchDetail(function (result) {
					AUIGrid.setGridData(auiGridDtl, result.list);
					$("#total_cnt").html(result.total_cnt);
					$("#curr_cnt").html(result.list.length);
					if (result.more_yn == 'Y') {
						moreFlag = "Y";
						page++;
					}
				});
			});
		}

		// 운영현황 상세결과 그리드생성
		function createAUIGridDtl() {
			const gridPros = {
				showRowNumColumn: true,
				headerHeights : [25, 75],
			};
			const columnLayout = [
				{
					headerText: "기본정보",
					children: [
						{
							headerText : "소유센터",
							dataField : "own_org_name",
							width : "70",
							style : "aui-center"
						},
						{
							headerText : "관리센터",
							dataField : "mng_org_name",
							width : "70",
							style : "aui-center"
						},
						{
							dataField: "own_org_code",
							visible: false
						},
						{
							dataField: "mng_org_code",
							visible: false
						},
						{
							headerText : "메이커",
							dataField : "maker_name",
							width : "70",
							style : "aui-center"
						},
						{
							dataField: "maker_cd",
							visible: false
						},
						{
							headerText : "모델명",
							dataField : "machine_name",
							width : "80",
							style : "aui-center"
						},
						{
							headerText : "차대번호",
							dataField : "body_no",
							width : "150",
							style : "aui-popup"
						},
						{
							headerText : "가동시간",
							dataField : "op_hour",
							width : "60",
							style : "aui-center",
						},
						{
							headerText : "년식",
							dataField : "made_year",
							width : "60",
							style : "aui-center",
						},
						{
							headerText : "매입일자",
							headerStyle : "aui-fold",
							dataField : "buy_dt",
							width : "70",
							dataType: "date",
							style : "aui-center",
							formatString: "yy-mm-dd"
						},
						{
							headerText : "월 기준<br>렌탈금액",
							headerStyle : "aui-fold",
							dataField : "rental30_price",
							width : "70",
							dataType: "numeric",
							formatString: "#,###",
							style : "aui-right",
						},
						{
							headerText : "월 감가",
							headerStyle : "aui-fold",
							dataField : "reduce_price",
							width : "70",
							dataType: "numeric",
							formatString: "#,###",
							style : "aui-right",
						},
					]
				},
				{
					headerText: "운용정보",
					children: [
						{
							headerText : "최대<br>임대매출",
							headerStyle : "aui-fold",
							dataField : "max_rental_amt",
							width : "100",
							dataType: "numeric",
							formatString: "#,###",
							style : "aui-right",
						},
						{
							headerText : "매출총액",
							headerStyle : "aui-fold",
							dataField : "rental_sale",
							width : "100",
							dataType: "numeric",
							formatString: "#,###",
							style : "aui-right",
						},
						{
							headerText : "총<br>가동율",
							headerStyle : "aui-fold",
							dataField : "util_rate",
							width : "50",
							dataType: "numeric",
							style : "aui-center",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "월 평균<br>가동시간",
							headerStyle : "aui-fold",
							dataField : "op_avg_mon",
							style : "aui-center",
							width : "60",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "기간매출",
							dataField : "total_amt",
							width : "100",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "기간<br>가동율<br>(매출기준)",
							dataField : "util_rate_amt",
							width : "80",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "기간<br>가동율<br>(임대일기준)",
							dataField : "util_rate_day",
							width : "80",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "기간 월<br>가동시간",
							dataField : "run_time_mon",
							width : "60",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "전년동기<br>매출",
							dataField : "last_total_amt",
							width : "100",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "전년동기<br>가동율<br>(매출기준)",
							dataField : "last_util_rate_amt",
							width : "80",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "전년동기<br>가동율<br>(임대일기준)",
							dataField : "last_util_rate_day",
							width : "80",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "전년동기 월<br>가동시간",
							dataField : "last_run_time_mon",
							width : "70",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "운용<br>일수",
							headerStyle : "aui-fold",
							dataField : "op_day",
							width : "55",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "운용<br>월수",
							headerStyle : "aui-fold",
							dataField : "op_month",
							width : "50",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "운영시간<br>대비<br>월 평균<br>렌탈금액",
							dataField : "mon_avg_amg",
							width : "100",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "총 장비<br>임대일수",
							headerStyle : "aui-fold",
							dataField : "day_cnt_total",
							width : "60",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
						},
					]
				},
				{
					headerText: "수리비",
					children: [
						{
							headerText : "수리비",
							headerStyle : "aui-fold",
							dataField : "rental_repair_price",
							width : "80",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "수리비<br>%",
							headerStyle : "aui-fold",
							dataField : "repair_rate",
							width : "60",
							style : "aui-center",
							dataType: "numeric",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "수리<br>위험도<br>(20%이상)",
							headerStyle : "aui-fold",
							dataField : "repair_rate_danger_yn",
							width : "70",
							style : "aui-center",
						}
					]
				},
				{
					headerText: "감가",
					children: [
						{
							headerText : "장비<br>가액",
							headerStyle : "aui-fold",
							dataField : "machine_price",
							width : "110",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "감가 총액",
							headerStyle : "aui-fold",
							dataField : "total_reduce_price",
							width : "100",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "잔여<br>감가<br>비용",
							dataField : "leftover_reduce_price",
							width : "100",
							style : "aui-right",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "감가종료<br>잔여개월",
							dataField : "reduce_over_leftover_mon",
							width : "60",
							style : "aui-center",
							dataType: "numeric",
							formatString: "#,###",
						},
					]
				},
				{
					headerText: "장비상세",
					dataField : "remark",
					width : "100",
					style : "aui-left",
				},
				{
					dataField : "rental_machine_no",
					visible : false
				}
			];

			auiGridDtl = AUIGrid.create("#auiGridDtl", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridDtl, []);
			AUIGrid.resize(auiGridDtl);

			AUIGrid.bind(auiGridDtl, "vScrollChange", function(event) {
				// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청
				if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
					goMoreData();
				}
			});

			// 차대번호 클릭 시 렌탈장비대장 팝업 호출
			AUIGrid.bind(auiGridDtl, "cellClick", function(event) {
				if (event.dataField !== "body_no") {
					return false;
				}

				const param = {
					rental_machine_no : event.item.rental_machine_no
				};

				$M.goNextPage('/rent/rent0201p01', $M.toGetParam(param), {popupStatus : ""});
			});
		}

		// 메인 그리드 조회
		function goSearch(param) {

			let sMon = $M.getValue("s_mon");
			let eMon = $M.getValue("e_mon");
			sMon = sMon.length === 1 ? "0" + sMon : sMon;
			eMon = eMon.length === 1 ? "0" + eMon : eMon;
			sStartDt = $M.getValue("s_year") + sMon + "01";
			sEndDt = $M.getValue("e_year") + eMon + "01";
			mngOrgCd = $M.getValue("s_mng_org_code");
			ownOrgCd = $M.getValue("s_own_org_code");

			param.s_start_dt = sStartDt;
			param.s_end_dt = sEndDt;
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

		// 펼침
        function fnChangeColumn(event) {
			const target = event.target || event.srcElement;
			if (!target)	return;
			const checked = target.checked;
            if (checked) {
                AUIGrid.showColumnByDataField(auiGridDtl, hideList);
            } else {
                AUIGrid.hideColumnByDataField(auiGridDtl, hideList);
            }
        }

		// 렌탈장비 운영현황 엑셀다운로드
		function fnDownloadExcel() {
			const exportProps = {};
			fnExportExcel(auiGrid, "렌탈장비 운영현황", exportProps);
	    }

		// 운영현황 상세결과 엑셀다운로드
		function fnExcelDownSec() {
			const exportProps = {};
			fnExportExcel(auiGridDtl, "렌탈장비 운영현황 상세결과", exportProps);
		}

		// 추가 데이터
		function goMoreData() {
			fnSearchDetail(function(result) {
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					AUIGrid.appendData("#auiGridDtl", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGridDtl).length);
				}
			});
		}

		function fnSearchDetail(successFunc) {
			isLoading = true;
			let sMon = $M.getValue("s_mon");
			let eMon = $M.getValue("e_mon");
			sMon = sMon.length === 1 ? "0" + sMon : sMon;
			eMon = eMon.length === 1 ? "0" + eMon : eMon;

			let param = {
				s_maker_cd : sMakerCd,
				s_machine_plant_seq : sMachinePlantSeq,
				s_mng_org_code : mngOrgCd,
				s_own_org_code : ownOrgCd,
				s_start_dt : $M.getValue("s_year") + sMon + "01",
				s_end_dt : $M.getValue("e_year") + eMon + "01",
				// pageing 처리 파라미터
				"page" : page,
				"rows" : $M.getValue("s_rows")
			};

			$M.goNextPageAjax(this_page + "/search/detail", $M.toGetParam(param), {method : 'GET', async: isAsync},
				function(result) {
					isLoading = false;
					isAsync = true;
					if (result.success) {
						successFunc(result);
					}
				}
			);
		}

	</script>
</head>
<body style="background : #fff;">
<form id="main_form" name="main_form">
	<div class="content-box">
		<div class="contents">
			<div class="search-wrap mt10">
				<!-- 검색영역 -->
				<table class="table table-fixed">
					<colgroup>
						<col width="60px">
						<col width="135px">
						<col width="15px">
						<col width="135px">
						<col width="60px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="70px">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th>조회기간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width80px">
										<select class="form-control" id="s_year" name="s_year">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
												<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
											</c:forEach>
										</select>
									</div>
									<div class="col width60px">
										<select class="form-control" id="s_mon" name="s_mon">
											<c:forEach var="i" begin="1" end="12" step="1">
												<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
							<td>
								<div> ~ </div>
							</td>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width80px">
										<select class="form-control" id="e_year" name="e_year">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
												<option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
											</c:forEach>
										</select>
									</div>
									<div class="col width60px">
										<select class="form-control" id="e_mon" name="e_mon">
											<c:forEach var="i" begin="1" end="12" step="1">
												<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_end_mon}">selected</c:if>>${i}월</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
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
			<!-- 상단 그리드 영역 -->
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
			<div id="auiGrid" style="margin-top: 5px; height: 230px;"></div>
			<!-- /상단 그리드 영역 -->
			<!-- 하단 그리드 영역 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<div class="left">
						<h4>상세결과</h4>
					</div>
					<div class="right">
						<label for="s_toggle_column">
							<input type="checkbox" id="s_toggle_column" onclick="fnChangeColumn(event)">펼침
						</label>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGridDtl" style="margin-top: 5px; height: 370px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
				</div>
			</div>
		</div>
	<!-- /contents 전체 영역 -->
	</div>
</form>	
</body>
</html>