<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridArea; // 영업지역 Grid
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		var resultData; // 검색결과 임시저장

		$(document).ready(function () {
			// createAUIGridArea(); // 처음에는 가려저 있기 때문에 재대로 만들어 지지 않음
			createAUIGrid();

			setTimeout(function() {
				goSearch();
			}, 1000);
		});

		// 문자발송
		function fnSendSms() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			var params = {
				"sms_send_type_cd": "2",
				"req_sendtarger_yn": "Y"
			};

			openSendSmsPanel($M.toGetParam(params));
		}


		function reqSendTargetList() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

			var parentTargetList = [];

			for (var i = 0; i < items.length; i++) {
				var obj = new Object();
				obj['phone_no'] = items[i].real_hp_no;
				obj['receiver_name'] = items[i].real_cust_name;
				obj['ref_key'] = items[i].cust_no;
				parentTargetList.push(obj);
			}

			return parentTargetList;
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_search_gubun", "s_cust_name", "s_mem_name", "s_hp_no", "s_use_times", "s_cust_grade_cd", "s_op_hour"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 구분변경
		function fnChangeGubun() {
			var s_not_have_consult_include_yn = $M.getValue("s_not_have_consult_include_yn");

			if (s_not_have_consult_include_yn == "Y") {
				$M.setValue("s_not_have_consult_include_yn", "Y");
			} else {
				$M.setValue("s_not_have_consult_include_yn", "N");
			}
		}

		// 신규고객등록
		// [재호] [3차-Q&A 14665] 영업대상고객 안건등록 수정 -> 기존 랜탈안건, 신규안건 로직 한 곳으로 통합
		// - 해당 cust010101 팝업 사용 X
		// function goAdd() {
			// $M.goNextPage("/cust/cust010101");
			// var poppupOption = "";
			// var params = {};
			// $M.goNextPage('/cust/cust010101', $M.toGetParam(params), {popupStatus: poppupOption});
		// }

		// 렌탈안건상담
		function goNew() {
			var poppupOption = "";
			var params = {};
			$M.goNextPage('/cust/cust0101p05', $M.toGetParam(params), {popupStatus: poppupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "마케팅대상고객");
		}

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}

		function showPlaceFilter(){

			var s_place_filter_yn = $M.getValue("s_place_filter_yn");

			if (s_place_filter_yn == "Y") {
				$M.setValue("s_place_filter_yn", "Y");
				$("#palce_area_filter").css('display', 'block');
				$("#result_area").addClass("col-10").removeClass("col-12");
				createAUIGridArea();
			} else {
				$M.setValue("s_place_filter_yn", "N");
				$("#palce_area_filter").css('display', 'none');
				$("#result_area").addClass("col-12").removeClass("col-10");
			}

			$("#auiGrid").resize();
			// 그리드를 초기화 하여 크기 재 계산
			if ( resultData ){

				AUIGrid.setGridData(auiGrid, resultData.list);
				$("#total_cnt").html(resultData.total_cnt);
				$("#curr_cnt").html(resultData.list.length);
				if (resultData.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				}
			}
		}

		function goSearch() {
			if($M.getValue("s_cust_name") == "" && $M.getValue("s_hp_no") == "" && $M.getValue("s_mem_name") == "" && $M.getValue("s_consult_mem_name") == ""
				&& ($M.getValue("s_start_dt") == "" || $M.getValue("s_end_dt") == "") && $M.getValue("s_op_hour") == ""
				&& $M.getValue("s_machine_name") == "" && $M.getValue("s_use_times") == ""  && $M.getValue("s_cust_grade_cd") == ""
				&& $M.getValue("s_maker_cd") == ""
				) {
				alert("[조회일자, 고객명, 휴대폰, 마케팅담당자명, 상담자, 메이커, 가동시간, 모델, 사용년수, 등급] 중 하나는 필수입니다.");
				return;
			}

			if( ($M.getValue("s_start_dt") != "" && $M.getValue("s_end_dt") == "") || ($M.getValue("s_start_dt") == "" && $M.getValue("s_end_dt") != "")) {
				alert("시작일 종료일을 모두 입력해 주세요.");
				return;
			}

			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";


			fnSearch(function (result) {
				resultData = result; // 검색결과 임시 저장
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				}
			});
		}

		// 조회
		function fnSearch(successFunc) {
			var frm = document.main_form;
			// validation check
			if($M.validation(frm) == false) {
				return;
			}

			if($M.getValue("s_start_search_dt") != "" && $M.getValue("s_end_search_dt") != "") {
				if ($M.checkRangeByFieldName("s_start_search_dt", "s_end_search_dt", true) == false) {
					return;
				}
			}

			var param = {
				"s_not_have_consult_include_yn": $M.getValue("s_not_have_consult_include_yn")  == "Y" ? "Y" : "N",
				"s_search_gubun": $M.getValue("s_search_gubun"),
				"s_start_search_dt": $M.getValue("s_start_dt"),
				"s_end_search_dt": $M.getValue("s_end_dt"),
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_mem_no": $M.getValue("s_mem_no"),
				"s_hp_no": $M.getValue("s_hp_no"),
				"s_use_times": $M.getValue("s_use_times"),
				"s_cust_grade_cd": $M.getValue("s_cust_grade_cd"),
				"s_op_hour": $M.getValue("s_op_hour"),
				"s_machine_plant_seq": $M.getValue("s_machine_plant_seq"),
				"s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"s_maker_cd_str" : $M.getValue("s_maker_cd"),
				"page": page,
				"rows": $M.getValue("s_rows"),
				"s_consult_mem_no": $M.getValue("s_consult_mem_no"),
				"s_consult_type_cd": $M.getValue("s_consult_type_cd"),
				// "s_end_yn": $M.getValue("s_end_yn"),
				"s_sale_area_code": '',
				"s_main_mng_yn" : $M.getValue("s_main_mng_yn") // 주요관리업체여부
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			// 류성진 - 지역 필터링 추가
			var s_sale_area_code = []
			if ( $M.getValue("s_place_filter_yn") == 'Y' ){

				// 체크된 지역
				var areaGridData = AUIGrid.getCheckedRowItems(auiGridArea);
				if(areaGridData.length <= 0) {
					alert("마케팅지역을 1곳 이상 선택해주세요.");
					return;
				}
				for (var i = 0; i < areaGridData.length; ++i) {
					s_sale_area_code.push(areaGridData[i].item.sale_area_code);
				}

				param.s_sale_area_code = s_sale_area_code.join("#");
			}
			// 지역 필터링 끝



			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						isLoading = false;
						if (result.success) {
							successFunc(result);
						}
					}
			);
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			}
		}

		function goMoreData() {
			fnSearch(function (result) {
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
			});
		}

		function createAUIGridArea() {
			var gridProsTree = {
				rowIdField: "sale_area_code",
				enableFilter: true,
				displayTreeOpen: false,
				showRowCheckColumn: true,
				rowCheckDependingTree: true,
				showRowNumColumn: false
			};

			var columnLayoutTree = [
				{
					headerText: "마케팅지역",
					dataField: "sale_area_name",
					style: "aui-left",
					editable: false,
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "마케팅구역코드",
					dataField: "sale_area_code",
					visible: false
				}
			];

			auiGridArea = AUIGrid.create("#auiGridArea", columnLayoutTree, gridProsTree);
			AUIGrid.setGridData(auiGridArea, ${list});
			$("#auiGridArea").resize();

			// 그리드 전체 체크
			AUIGrid.setAllCheckedRows(auiGridArea, true);
		}

		//그리드생성
		function createAUIGrid() {
			var baseDt = $M.dateFormat($M.addMonths($M.toDate("${inputParam.s_current_dt}"), -3), "yyyyMMdd");

			var gridPros = {
				rowIdField: "_$uid",
				height: 555,
				showRowCheckColumn: true,
				headerHeight : 40,
				rowStyleFunction: function (rowIndex, item) {
					if(item.red_yn == "Y") {
						return "aui-color-red";
					}
					return "";
				}
			};

			var columnLayout = [
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "130",
					minWidth : "120",
					style: "aui-center aui-popup"
				},
				{
					dataField: "real_cust_name",
					visible: false
				},
				{
					dataField: "cust_no",
					visible: false
				},
				{
					dataField: "cust_counsel_seq",
					visible: false
				},
				{
					dataField: "consult_type_cd",
					visible: false
				},
				{
					headerText: "회원구분",
					headerStyle : "aui-fold",
					dataField: "cust_type_name",
					width : "70",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "고객등급",
					dataField: "show_cust_grade_cd_str",
					width : "70",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "생일",
					headerStyle : "aui-fold",
					dataField: "birth_dt",
					dataType: "date",
					width : "70",
					minWidth : "60",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "휴대폰",
					dataField: "hp_no",
					width : "110",
					minWidth : "100",
					style: "aui-center"
				},
				{
					dataField: "real_hp_no",
					visible: false
				},
				{
					headerText: "주소",
					dataField: "addr",
					width : "180",
					minWidth : "170",
					style: "aui-left"
				},
				{
					headerText: "마케팅",
					dataField: "sale_mem_name",
					width : "70",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "서비스",
					dataField: "service_mem_name",
					width : "70",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "차대번호",
					headerStyle : "aui-fold",
					dataField: "body_no",
					width : "150",
					minWidth : "140",
					style: "aui-center"
				},
				{
					dataField: "machine_plant_seq",
					visible: false
				},
				{
					headerText: "모델구분",
					dataField: "cust_machine_type",
					width : "115",
					minWidth : "110",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == 'OWN' || value == 'EXT') {
							return "보유모델";
						} else if (value == 'CON') {
							return "상담모델";
						} else {
							return "";
						}
					}
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "115",
					minWidth : "110",
					style: "aui-center"
				},
				{
					headerText : "보유기종여부",
					dataField : "machine_yn",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var machineYn = "미보유";
						if (value == "Y") {
							if (item["cust_machine_type"] == "OWN") {
								machineYn = "보유";
							} else if (item["cust_machine_type"] == "EXT") {
								machineYn = "보유(임의)";
							}
						}
						return machineYn;
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == "Y") {
							return "aui-popup aui-center";
						} else {
							return "aui-center";
						}
					},
				},
				{
					headerText : "연식",
					dataField : "made_year",
					width : "50",
					minWidth : "50",
					style : "aui-center",
					visible: true
				},
				{
					headerText: "장비출하일",
					headerStyle : "aui-fold",
					dataField: "out_dt",
					dataType: "date",
					width : "70",
					minWidth : "60",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "사용년수",
					headerStyle : "aui-fold",
					dataField: "use_times",
					width : "70",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "최근정비일자",
					headerStyle : "aui-fold",
					dataField: "job_dt",
					dataType: "date",
					width : "80",
					minWidth : "70",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "가동시간",
					headerStyle : "aui-fold",
					dataField: "op_hour",
					width : "70",
					minWidth : "60",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value > 0) {
							return AUIGrid.formatNumber(value, "#,###") + " h";
						} else {
							return "";
						}
					}
				},
				{
					headerText: "가동시간(SA-R)",
					headerStyle : "aui-fold",
					dataField: "sar_op_hour",
					width : "110",
					minWidth : "100",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value > 0) {
							return AUIGrid.formatNumber(value, "#,###") + " h";
						} else {
							return "";
						}
					}
				},
				{
					headerText : "장비용도",
					dataField : "mch_use_name",
					headerStyle : "aui-fold",
					width : "70",
					minWidth : "60",
					style : "aui-left",
				},
				{
					headerText : "주기장주소",
					dataField : "curr_addr",
					headerStyle : "aui-fold",
					width : "150",
					minWidth : "120",
					style : "aui-left",
				},
				{
					headerText: "안건상담일",
					dataField: "consult_dt_max",
					dataType: "date",
					width : "70",
					minWidth : "60",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "최종안건상담일",
					dataField: "last_consult_dt",
					dataType: "date",
					width : "90",
					minWidth : "60",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					dataField: "consult_dt_min",
					dataType: "date",
					width : "70",
					minWidth : "60",
					style: "aui-center",
					formatString: "yy-mm-dd",
					visible: false
				},
				{
					headerText: "상담횟수",
					dataField: "consult_cnt",
					style: "aui-center",
					width : "70",
					minWidth : "60"
				},
				{
					headerText: "미결일자",
					dataField: "uncomplete_dt",
					dataType: "date",
					formatString: "yy-mm-dd",
					width : "70",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "미결수",
					dataField: "uncomplete_cnt",
					style: "aui-center",
					width : "70",
					minWidth : "60"
				},
				/* Q&A(14665) : 안건상담 구조변경
				{
					headerText: "상담상태",
					dataField: "end_yn",
					style: "aui-center",
					width : "60",
					minWidth : "50",
					visible: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "Y") {
							return "완료"
						} else {
							return "상담중";
						}
					}
				},*/
				{
					headerText: "상담구분",
					dataField: "consult_type_name",
					style: "aui-center",
					width : "60",
					minWidth : "50"
				},
				{
					headerText: "지역",
					dataField: "area_si",
					style: "aui-center",
					width : "60",
					minWidth : "50"
				},
				{
					headerText: "개인정보<br/>수집동의",
					headerStyle : "aui-fold",
					dataField: "personal_yn",
					width : "65",
					minWidth : "65",
					style: "aui-center"
				},
				{
					headerText: "제3자<br/>제공동의",
					headerStyle : "aui-fold",
					dataField: "three_yn",
					width : "65",
					minWidth : "65",
					style: "aui-center"
				},
				{
					headerText: "마케팅<br/>이용동의",
					headerStyle : "aui-fold",
					dataField: "marketing_yn",
					width : "65",
					minWidth : "65",
					style: "aui-center"
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == 'cust_name') {
				// Q&A(14665) : 안건상담 구조변경
					var params = {
						"cust_no": event.item.cust_no,
						"s_dt_yn": "N",
						"s_machine_plant_seq" : event.item.machine_plant_seq,
						// "s_start_dt": event.item.consult_dt_min,
						// "s_end_dt": event.item.consult_dt_max,
						// "s_machine_plant_seq": event.item.machine_plant_seq
					};
					if (event.item.machine_plant_seq === "") {
						params.s_machine_plant_seq = "blank";
					}
					$M.goNextPage('/cust/cust0101p05', $M.toGetParam(params), {popupStatus: ""});
				/*
					if (event.item.consult_type_cd == '03') {
						var params = {
							"cust_consult_seq": event.item.cust_consult_seq,
							"cust_no": event.item.cust_no,
							"own_machine_seq": event.item.own_machine_seq
						};

						var poppupOption = "";
						$M.goNextPage('/cust/cust0101p04', $M.toGetParam(params), {popupStatus: poppupOption});
					} else {
						var params = {
							"cust_consult_seq": event.item.cust_consult_seq,
							"cust_no": event.item.cust_no,
							"own_machine_seq": event.item.own_machine_seq
						};

						var poppupOption = "";
						$M.goNextPage('/cust/cust0101p01', $M.toGetParam(params), {popupStatus: poppupOption});
					}*/
				} else if (event.dataField == "machine_yn" && event.item["machine_yn"] == "Y") {
					var param = {
						"cust_no": event.item["cust_no"]
					}
					$M.goNextPage('/comp/comp0308', $M.toGetParam(param), {popupStatus : ""});
				}
			});

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
		}
		
		function fnSetMem(data) {
			$M.setValue("s_mem_no", data.mem_no);
			$M.setValue("s_mem_name", data.name);
		}
		
		function fnSetConsultMem(data) {
			$M.setValue("s_consult_mem_no", data.mem_no);
			$M.setValue("s_consult_mem_name", data.mem_name);
		}
		
		function fnMemClear() {
			$M.setValue("s_mem_no", "");
			$M.setValue("s_mem_name", "");
		}
		
		function fnConsultMemClear() {
			$M.setValue("s_consult_mem_no", "");
			$M.setValue("s_consult_mem_name", "");
		}
		
		function fnAreaClear() {
			$M.setValue("sale_area_name", "");
			$M.setValue("s_sale_area_code", "");
		}
		
		// 담당지역 결과
// 		function setSaleAreaInfo(data) {
// 			$M.setValue("sale_area_name", data.area_si);
// 			$M.setValue("s_sale_area_code", data.sale_area_code);
//
// // 			$M.setValue("area_si", data.area_si);
// // 			$M.setValue("sale_area_code", data.sale_area_code);
// // 			$M.setValue("center_org_name", data.center_name);
// // 			$M.setValue("center_org_code", data.center_org_code);
// // 			$M.setValue("service_mem_name", data.servie_mem_name);
// // 			$M.setValue("service_mem_no", data.service_mem_no);
// 		}
		
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
<div class="content-wrap">
	<div class="content-box">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<div class="contents">
			<!-- 좌측영역 -->

<%--			<div class="row">--%>
<%--				<div class="col-2" id="palce_area_filter">--%>

<%--			<div id="auiGridArea" style="margin-top: 1px; height: 700px;"></div>--%>
<%--				</div>--%>
<%--				<!-- /좌측영역 -->--%>
<%--				<div class="col-10">--%>
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="130px">
								<col width="280px">
								<col width="60px">
								<col width="120px">
								<col width="60px">
								<col width="120px">
								<col width="100px">
								<col width="120px">
								<col width="60px">
								<col width="120px">
								<col width="70px">
								<col width="120px">
								<col width="50px">
								<col width="120px">
								<col width="">
								<col width="40px">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<select class="form-control" name="s_search_gubun" id="s_search_gubun">
										<option value="">전체</option>
										<option value="out_dt">장비출하일</option>
										<option value="consult_dt">안건상담일</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group dev_nf">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group dev_nf">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일">
											</div>
										</div>

										<!-- <details data-popover="up">

											   </details> -->
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
											<jsp:param name="st_field_name" value="s_start_dt"/>
											<jsp:param name="ed_field_name" value="s_end_dt"/>
											<jsp:param name="click_exec_yn" value="Y"/>
											<jsp:param name="exec_func_name" value="goSearch();"/>
										</jsp:include>
									</div>
								</td>
								<th>고객명</th>
								<td>
									<input type="text" class="form-control  width120px" name="s_cust_name" id="s_cust_name">
								</td>
								<th>휴대폰</th>
								<td>
									<input type="text" class="form-control  width120px" placeholder="-없이 숫자만" id="s_hp_no" name="s_hp_no"/>
								</td>
								<th>마케팅담당자</th>
								<td>
		<!-- 							<input type="text" class="form-control  width120px" name="s_mem_name" id="s_mem_name"/> -->
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="s_mem_name" name="s_mem_name" placeholder="돋보기 클릭하여 조회" readonly="readonly" style="background: white" alt="" onclick="javascript:fnMemClear();">
										<input type="hidden" id="s_mem_no" name="s_mem_no" value="" >
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('fnSetMem', 'N')"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th>상담자</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="s_consult_mem_name" name="s_consult_mem_name" placeholder="돋보기 클릭하여 조회" readonly="readonly" style="background: white" alt="" onclick="javascript:fnConsultMemClear();">
										<input type="hidden" id="s_consult_mem_no" name="s_consult_mem_no" value="" >
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('fnSetConsultMem', 'N')"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th>가동시간</th>
								<td>
									<input type="text" class="form-control  width120px" name="s_op_hour" id="s_op_hour" datatype="int" placeholder="시간(h)이상"/>
								</td>
								<th>모델</th>
								<td>
									<div class="form-row inline-pd pl5">
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
											<jsp:param name="required_field" value=""/>
											<jsp:param name="s_maker_cd" value=""/>
											<jsp:param name="s_machine_type_cd" value=""/>
											<jsp:param name="s_sale_yn" value=""/>
											<jsp:param name="readonly_field" value=""/>
											<jsp:param name="execFuncName" value=""/>
											<jsp:param name="focusInFuncName" value=""/>
										</jsp:include>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
						<table class="table">
							<colgroup>
								<col width="40px">
								<col width="350px">

								<col width="65px">
								<col width="120px">

								<col width="55px">
								<col width="130px">
								<%-- 상담구분 --%>
<%--								<col width="90px">--%>
<%--								<col width="80px">--%>
								<%-- 상담상태 --%>
<%--								<col width="100px">--%>
								<col width="135px">
								<col width="120px">

								<col width="">
								<col width="120px">
							</colgroup>
							<tbody>
								<tr>
									<th>메이커</th>
									<td>
										<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd" name="s_maker_cd" easyui="combogrid"
											   easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
									</td>
									<th>사용년수</th>
									<td>
										<select class="form-control" style="width: 96%;" name="s_use_times" id="s_use_times">
											<option value="">- 전체 -</option>
											<option value="01">2년이하</option>
											<option value="02">3~4년식</option>
											<option value="03">5~6년식</option>
											<option value="04">7년이상</option>
										</select>
									</td>
									<th>등급</th>
									<td>
										<select class="form-control" style="width: 90%;" name="s_cust_grade_cd" id="s_cust_grade_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['CUST_GRADE']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
<%--									<th>상담구분</th>--%>
<%--									<td>--%>
<%--										<select class="form-control width80px" name="s_consult_type_cd" id="s_consult_type_cd">--%>
<%--											<option value="">- 전체 -</option>--%>
<%--											<c:forEach items="${codeMap['CONSULT_TYPE']}" var="item">--%>
<%--												<c:if test="${item.code_value ne '02'}"><option value="${item.code_value}">${item.code_name}</c:if></option> &lt;%&ndash; 대차 제외 &ndash;%&gt;--%>
<%--											</c:forEach>--%>
<%--										</select>--%>
<%--									</td>--%>
										<%--	14666 류성진 삭제	--%>
									<%--<th>상담상태</th>--%>
		<%--							<td>--%>
		<%--								<select class="form-control width80px" name="s_end_yn" id="s_end_yn">--%>
		<%--									<option value="">- 전체 -</option>--%>
		<%--									<option value="N">상담중</option>--%>
		<%--									<option value="Y">완료</option>--%>
		<%--								</select>--%>
		<%--							</td>--%>
<%--									<th>담당지역</th>--%>
<%--									<td>--%>
<%--										<div class="input-group">--%>
<%--											<input type="text" class="form-control border-right-0" id="sale_area_name" name="sale_area_name" placeholder="돋보기 클릭하여 조회" readonly="readonly" style="background: white" alt="" onclick="javascript:fnAreaClear();">--%>
<%--											<input type="hidden" id="s_sale_area_code" name="s_sale_area_code" value="" >--%>
<%--											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>--%>
<%--										</div>--%>
<%--									</td>--%>
									<td class="pl10">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_not_have_consult_include_yn" name="s_not_have_consult_include_yn"  checked="checked" value="Y" />
											<label class="form-check-input" for="s_not_have_consult_include_yn">미상담 고객 포함</label>
										</div>
									</td>
									<th>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_main_mng_yn" name="s_main_mng_yn" value="Y">
											<label class="form-check-label mr5" for="s_main_mng_yn">주요관리업체</label>
										</div>
									</th>
									<th>지역 필터</th>
									<td class="pl20">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_place_filter_yn" name="s_place_filter_yn" value="Y" onclick="javascript:showPlaceFilter();">
											<label class="form-check-input" for="s_place_filter_yn">지역 필터</label>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>

					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="row">
						<div id="palce_area_filter" class="col-2" style="display: none">
							<div id="auiGridArea" style="margin-top: 1px; height: 510px;"></div>
						</div>
						<div id="result_area" class="col-12"> <!-- 결과물 영역 -->
							<div class="title-wrap mt12">
								<h4>조회결과</h4>
								<div class="btn-group">
									<div class="right">
										<div class="form-check form-check-inline">
											<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
												<input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
												<label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
											</c:if>
											<label for="s_toggle_column" style="color:black;">
												<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
											</label>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<!-- /그리드 타이틀, 컨트롤 영역 -->

							<div id="auiGrid" style="margin-top: 5px;height: 480px;"></div>

							<!-- 그리드 서머리, 컨트롤 영역 -->
							<div class="btn-group mt5">
								<div class="left">
									<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
								</div>
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>
							</div>
						</div>
					</div>
					<%--	그리드 영역	--%>
<%--				</div>--%>
<%--			</div>--%>
			<!-- /그리드 서머리, 컨트롤 영역 -->
			<!-- 관리등급기준 설명 -->
			<div class="alert alert-secondary mt10">
				<div class="title">
					<i class="material-iconserror font-16"></i>
					관리등급기준
				</div>
				<div class="row">
					<ul class="col-8">
						<c:forEach var="code" items="${codeMap['CUST_GRADE']}">
							<li>${code.code_name} : ${code.code_desc}</li>
						</c:forEach>
<%--						<li>A : 자사 판매 장비 3대 이상 보유한 고객</li>--%>
<%--						<li>B : 자사 판매 장비 2대 보유한 고객</li>--%>
<%--						<li>C : 자사 판매 장비 1대 보유</li>--%>
<%--						<li>F : 거래 신용 문제로 주의해야 할 악성 고객</li>--%>
<%--						<li>N : New 의 약자로 신차 구매 가능성 있는 신규 안건 등록 고객</li>--%>
<%--						<li>E : Exchange 의 약자로 자사 장비 혹은 타사 장비를 가지고 있지만 장비를 곧 교체할 가능성이 있는 고객</li>--%>
<%--						<li>Z : 타사 장비를 가지고 있는 고객으로 시장 내 관리가 필요한 고객</li>--%>
<%--						<li>R : Rental 의 약자로 렌탈 이용 고객</li>--%>
<%--						<li>T : NEZR을 제외한 고객(기본고객)</li>--%>
<%--						<li>H : 2년간 한번도 매출이 발생하지 않은 고객</li>--%>
<%--						<li>BL : 블랙리스트(진상고객)</li>--%>
					</ul>
				</div>
			</div>
			<!-- /관리등급기준 설명 -->
		</div>
	</div>
	<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>