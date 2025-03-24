<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비 수요분석 > 모델별 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-01-18 13:36:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid; // 상단 그리드
		var auiGridDtl; // 상세결과 그리드
		var mngOrgCd; // 조회조건 관리센터
		var ownOrgCd; // 조회조건 소유센터
		var sStartDt; // 조회조건 시작년월
		var sEndDt; // 조회조건 끝년월
		var sMakerCd;
		var sMachinePlantSeq;
		let foldList = []; // 펼침 & 접힘 항목
		let dtlFoldList = []; // 상세결과 펼침 & 접힘 항목

		/* 페이징처리 관련 변수 */
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var isAsync = true;

		$(document).ready(function() {
			createAUIGrid();
			createAUIGridDtl();
			fnAreaClear();

			// 펼침 컬럼 목록 생성
			AUIGrid.getColumnInfoList(auiGrid).forEach(map => {
				if (map.headerStyle && map.headerStyle === "aui-fold") foldList.push(map.dataField);
			});
			AUIGrid.getColumnInfoList(auiGridDtl).forEach(map => {
				if (map.headerStyle && map.headerStyle === "aui-fold") dtlFoldList.push(map.dataField);
			});
			// 기본값 접힘
			AUIGrid.hideColumnByDataField(auiGrid, foldList);
			AUIGrid.hideColumnByDataField(auiGridDtl, dtlFoldList);
		});

		// 상단 메인 그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				headerHeight : 30,
				showFooter : true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "90",
					style : "aui-center"
				},
				{
					dataField: "maker_cd",
					visible: false
				},
				{
					headerText : "모델",
					dataField : "machine_name",
					width : "100",
					style : "aui-popup"
				},
				{
					dataField : "machine_plant_seq",
					visible : false
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
					headerText : "당년<br>총 임대매출",
					dataField : "total_amt",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "조정렌탈료",
					headerStyle: "aui-fold",
					dataField : "discounted_rental_price",
					width : "90",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "운임비",
					headerStyle: "aui-fold",
					dataField : "transport_amt",
					width : "90",
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
					headerText : "당년<br>총 임대일수",
					dataField : "days_cnt_tot",
					width : "80",
					dataType: "numeric",
					formatString: "#,###",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == ""){
							return "";
						}else {
							return AUIGrid.formatNumber(value, "#,##0") + "(일)";
						}
					},
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
					headerText : "당년 총 이용<br>고객 수<br>(중복제외)",
					dataField : "rent_cust_cnt",
					width : "75",
					style : "aui-center aui-popup",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "동일모델<br>재임대 고객",
					dataField : "re_rent_cnt",
					width : "70",
					style : "aui-center aui-popup",
					dataType: "numeric",
					formatString: "#,###",
				},
				
				{
					headerText : "재임대<br>고객 비율(%)",
					dataField : "re_rent_rate",
					width : "80",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
					labelFunction : window.parent.percentageLabelFunction
				},
				{
					headerText : "당년<br>총 임대횟수",
					dataField : "rent_cnt",
					width : "70",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년 기간별 이용 비율",
					dataField : "",
					children : [
						{
							headerText : "7일 이하",
							dataField : "day7_cnt",
							style : "aui-center",
							width : "60",
							minWidth : "60",
						},
						{
							headerText : "비율(%)",
							dataField : "day7_rate",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "8~31일",
							dataField : "day31_cnt",
							width : "60",
							minWidth : "60",
						},
						{
							headerText : "비율(%)",
							dataField : "day31_rate",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "32일 이상",
							dataField : "day32_cnt",
							width : "60",
							minWidth : "60",
						},
						{
							headerText : "비율(%)",
							dataField : "day32_rate",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
					]
				},
				{
					headerText : "수리비",
					dataField : "rental_repair_price",
					width : "100",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
			];
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "maker_name",
					colSpan : 3
				},
				{
					// 당년 총 임대매출
					dataField: "total_amt",
					positionField: "total_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					// 조정렌탈료
					dataField: "discounted_rental_price",
					positionField: "discounted_rental_price",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					// 운임비
					dataField: "transport_amt",
					positionField: "transport_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					// 수리비
					dataField: "rental_repair_price",
					positionField: "rental_repair_price",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);

			// 모델명 클릭 시 상세조회
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// check
				if(event.dataField == "machine_name") {
					goSearchDetail(event.item.machine_plant_seq);
				} else if(event.dataField == "rent_cust_cnt" || event.dataField == "re_rent_cnt"){
					var params = {
						"type": "3", //렌탈료
						"s_machine_plant_seq": event.item.machine_plant_seq,
						"s_start_dt": $M.getValue("s_year") + "0101",
						"s_end_dt": $M.getValue("s_year") + "1231",
						"re_rent_yn": event.dataField == "re_rent_cnt" ? "Y" : "",
						"s_year" : $M.getValue("s_year"),
						"s_mng_org_code" : $M.getValue("s_mng_org_code"),
						"s_own_org_code" : $M.getValue("s_own_org_code"),
						"s_machine_name" : $M.getValue("s_machine_name"),
						"s_body_no" : $M.getValue("s_body_no"),
						"s_made_dt" : $M.getValue("s_made_dt"),
						"s_mch_use_cd" : $M.getValue("s_mch_use_cd"),
						"s_sale_area_code_str" : $M.getValue("s_sale_area_code_str"),
					}
					var popupOption = "";
					$M.goNextPage('/serv/serv0501p06', $M.toGetParam(params), {popupStatus: popupOption});
				}
				
			});
		}

		// 운영현황 상세결과 그리드생성
		function createAUIGridDtl() {
			var gridPros = {
				showRowNumColumn: true,
				headerHeight : 30,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText : "관리센터",
					dataField : "mng_org_name",
					width : "60",
					style : "aui-center"
				},
				{
					dataField: "mng_org_code",
					visible: false
				},
				{
					headerText : "소유센터",
					dataField : "own_org_name",
					width : "60",
					style : "aui-center"
				},
				{
					dataField: "own_org_code",
					visible: false
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "60",
					style : "aui-center"
				},
				{
					dataField: "maker_cd",
					visible: false
				},
				{
					headerText : "모델",
					dataField : "machine_name",
					width : "100",
					style : "aui-center"
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "150",
					style : "aui-center aui-popup"
				},
				{
					headerText : "연식",
					dataField : "made_year",
					width : "50",
					style : "aui-center"
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					width : "60",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
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
					headerText : "당년<br>총 임대매출",
					dataField : "total_amt",
					width : "110",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "조정렌탈료",
					headerStyle: "aui-fold",
					dataField : "discounted_rental_price",
					width : "90",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "운임비",
					headerStyle: "aui-fold",
					dataField : "transport_amt",
					width : "90",
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
					headerText : "당년<br>총 임대일수",
					dataField : "day_cnt",
					width : "80",
					dataType: "numeric",
					formatString: "#,###",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == ""){
							return "";
						}else {
							return AUIGrid.formatNumber(value, "#,##0") + "(일)";
						}
					},
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
					headerText : "총 임대횟수",
					dataField : "total_rent_cnt",
					width : "100",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년 임대횟수",
					dataField : "rent_cnt",
					width : "100",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "당년 기간별 이용 비율",
					dataField : "",
					children : [
						{
							headerText : "7일 이하",
							dataField : "day7_cnt",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "비율(%)",
							dataField : "day7_rate",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "8~31일",
							dataField : "day31_cnt",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "비율(%)",
							dataField : "day31_rate",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "32일 이상",
							dataField : "day32_cnt",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							dataType: "numeric",
							formatString: "#,###",
						},
						{
							headerText : "비율(%)",
							dataField : "day32_rate",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
					]
				},
				{
					headerText : "ROI",
					headerStyle : "aui-fold",
					dataField : "roi_rate",
					width : "60",
					style : "aui-center",
					labelFunction : window.parent.percentageLabelFunction,
				},
				{
					headerText : "잔여비용",
					headerStyle : "aui-fold",
					dataField : "left_amt",
					style : "aui-right",
					width : "90",
					dataType : "numeric",
					formatString : "#,###",
				},
				{
					headerText : "마케팅잔여비용",
					headerStyle : "aui-fold",
					dataField : "marketing_left_amt",
					width : "90",
					style : "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText : "수리비",
					dataField : "rental_repair_price",
					style : "aui-right",
					width : "90",
					dataType : "numeric",
					formatString : "#,###",
				},
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "mng_org_name",
					colSpan : 3
				},
				{
					dataField: "total_amt",
					positionField: "total_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					// 조정렌탈료
					dataField: "discounted_rental_price",
					positionField: "discounted_rental_price",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					// 운임비
					dataField: "transport_amt",
					positionField: "transport_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					// 수리비
					dataField: "rental_repair_price",
					positionField: "rental_repair_price",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];
			auiGridDtl = AUIGrid.create("#auiGridDtl", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGridDtl, footerLayout);
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

				var param = {
					rental_machine_no : event.item.rental_machine_no
				};

				$M.goNextPage('/rent/rent0201p01', $M.toGetParam(param), {popupStatus : ""});
			});
		}

		// 메인 그리드 조회
		function goSearch(param) {

			param.s_year = $M.getValue("s_year")
			param.s_maker_cd = param.s_maker_cd == null ? $M.getValue("s_maker_cd") : param.s_maker_cd;
			param.s_mng_org_code = $M.getValue("s_mng_org_code");
			param.s_own_org_code = $M.getValue("s_own_org_code");
			param.s_machine_name = $M.getValue("s_machine_name");
			param.s_body_no = $M.getValue("s_body_no");
			param.s_made_dt = $M.getValue("s_made_dt");
			param.s_mch_use_cd = $M.getValue("s_mch_use_cd");
			param.s_sale_area_code_str = $M.getValue("s_sale_area_code_str");

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}

		// 메이커별 조회
		function goSearchMaker(makerCd) {
			var param = {
				s_maker_cd : makerCd
			};
			goSearch(param);
		}

		// 지역조회 결과
		function setSaleAreaInfo(data) {
			$M.setValue("area_name", data.area_name);
			$M.setValue("s_sale_area_code_str", data.s_area_sale_code_str);
		}

		// 지역 초기화
		function fnAreaClear() {
			$M.setValue("area_name", "- 전체 -");
			$M.setValue("s_sale_area_code_str", "");
		}
		
		// 렌탈장비 운영현황 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈장비 수요분석(모델별)", exportProps);
		}

		// 운영현황 상세조회 엑셀다운로드
		function fnExcelDownload() {
			var exportProps = {};
					
			fnExportExcel(auiGridDtl, "렌탈장비 수요분석(모델별) 상세조회", exportProps);
		}
        
        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_machine_name", "s_body_no"];
            $.each(field, function() {
                if(fieldObj.name == this) {
                    goSearch();
                }
            });
        }
        
		function goSearchDetail(machinePlantSeq) {
			var param = {
				s_year : $M.getValue("s_year"),
				s_mng_org_code : $M.getValue("s_mng_org_code"),
				s_own_org_code : $M.getValue("s_own_org_code"),
				s_machine_name : $M.getValue("s_machine_name"),
				s_body_no : $M.getValue("s_body_no"),
				s_made_dt : $M.getValue("s_made_dt"),
				s_mch_use_cd : $M.getValue("s_mch_use_cd"),
				s_sale_area_code_str : $M.getValue("s_sale_area_code_str"),
				s_machine_plant_seq : machinePlantSeq
			};

			$M.goNextPageAjax(this_page + "/search/detail", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if (result.success) {
							AUIGrid.setGridData(auiGridDtl, result.list);
							$("#total_detail_cnt").html(result.total_detail_cnt);
						}
					}
			);
		}
		// 수요 분석 그래프(지역별 / 업종별) 팝업
		function goFirstGraphPopup() {
			var params = {
				s_year : $M.getValue("s_year"), // 조회년도
				s_mch_use_cd : $M.getValue("s_mch_use_cd"), // 장비용도코드
				mch_use_name : $("#s_mch_use_cd option:selected").text(), // 장비용도명
				s_sale_area_code_str : $M.getValue("s_sale_area_code_str"),
				area_name : $M.getValue("area_name"),
			};

			var popupOption = '';
			$M.goNextPage('/rent/rent0404p05', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 펼침
		function fnChangeColumn() {
			const target = document.getElementById('s_toggle_column').checked;
			if (target) {
				AUIGrid.showColumnByDataField(auiGrid, foldList);
			} else {
				AUIGrid.hideColumnByDataField(auiGrid, foldList);
			}
		}

		// 상세 펼침
		function fnChangeColumnDtl() {
			const target = document.getElementById('s_toggle_dtl_column').checked;
			if (target) {
				AUIGrid.showColumnByDataField(auiGridDtl, dtlFoldList);
			} else {
				AUIGrid.hideColumnByDataField(auiGridDtl, dtlFoldList);
			}
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
						<col width="80px">
						<col width="50px">
						<col width="100px">
						<col width="40px">
						<col width="120px">
						<col width="60px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="40px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="40px">
						<col width="230px">
						<col width="*">
					</colgroup>
					<tbody>
					<tr>
						<th>조회기간</th>
						<td>
							<select class="form-control" id="s_year" name="s_year">
								<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
									<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
									<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
								</c:forEach>
							</select>
						</td>
						<th>메이커</th>
						<td>
							<select id="s_maker_cd" name="s_maker_cd" class="form-control">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['MAKER']}" var="item">
									<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th>모델</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<div class="input-group">
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
											<jsp:param name="required_field" value="s_machine_name"/>
											<jsp:param name="s_sale_yn" value="N"/>
										</jsp:include>
									</div>
								</div>
							</div>
						</td>
						<th>차대번호</th>
						<td>
							<input type="text" class="form-control" id="s_body_no" name="s_body_no">
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
						<th>소유센터</th>
						<td>
							<select class="form-control" name="s_own_org_code">
								<option value="">- 전체 -</option>
								<c:forEach items="${orgCenterList}" var="item">
									<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if>>${item.org_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>연식</th>
						<td>
							<select class="form-control" id="s_made_dt" name="s_made_dt">
								<option value="">- 전체 -</option>
								<option value="2">2년이하</option>
								<option value="3~4">3~4년식</option>
								<option value="5~6">5~6년식</option>
								<option value="7">7년 이상</option>
							</select>
						</td>
						<th>장비용도</th>
						<td>
							<select class="form-control" id="s_mch_use_cd" name="s_mch_use_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['MCH_USE']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>지역</th>
						<td>
							<div class="col-12">
								<div class="input-group" >
									<input type="text" class="form-control border-right-0" id="area_name" name="area_name" required="required" readonly="readonly" alt="지역">
									<input type="hidden" id="s_sale_area_code_str" name="s_sale_area_code_str"/>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>
									<button type="button" class="btn btn-default btn-icon" onclick="javascript:fnAreaClear();"><i class="material-iconsclose text-default" ></i></button>
								</div>
							</div>
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
					<div class="right">
						<label for="s_toggle_column" style="margin-right: 5px;">
							<input type="checkbox" id="s_toggle_column" style="margin: 2px .3125rem 1px 5px;" onclick="fnChangeColumn()">펼침
						</label>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 230px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>
			</div>
			<!-- /상단 그리드 영역 -->
			<!-- 하단 그리드 영역 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<div class="left">
						<h4>상세결과</h4>
					</div>
					<div class="right">
						<label for="s_toggle_dtl_column" style="margin-right: 5px;">
							<input type="checkbox" id="s_toggle_dtl_column" style="margin: 2px .3125rem 1px 5px;" onclick="fnChangeColumnDtl()">펼침
						</label>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGridDtl" style="margin-top: 5px; height: 370px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong id="total_detail_cnt" class="text-primary">0</strong>건
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>