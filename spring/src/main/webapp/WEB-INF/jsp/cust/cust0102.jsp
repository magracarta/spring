<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 13:01:58

-- 고객조회 쿼리 수정, 검색조건 추가 by 박예진
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
	<!-- script -->
	<script type="text/javascript">

		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		var machinePlantSeqArr = [];

		var resultData; // 검색결과 임시저장

		$(document).ready(function() {
      /* q&a - 17566 고객조회/등록 + 기호 삭제, 모든 조건 노출로 변경 */
<%--			$('.search-expand').toggleClass("dpn");--%>

<%--			// 아코디언--%>
<%--			$(".triangle-down-right").click(function() {--%>
<%--				$(this).find("i").toggleClass("icon-btn-triangle-up icon-btn-triangle-down");--%>
<%--				$('.search-expand').toggleClass("dpn");--%>

<%--				if($(".search-expand").hasClass("dpn") === true) {--%>
<%--					$M.setValue("s_sale_start_dt", "");--%>
<%--					$M.setValue("s_sale_end_dt", "");--%>
<%--				}--%>
<%--				// 2021.04.14 SR 추가 수정요청사항으로 토글 오픈 시 판매일자 디폴트 기간 삭제--%>
<%--// 				else {--%>
<%--// 					$M.setValue("s_sale_start_dt", "19990101");			// 21.02.18 최승희 대리님 요청으로 99년도부터 조회하도록 수정--%>
<%--// 					$M.setValue("s_sale_end_dt", "${inputParam.s_end_dt}");--%>
<%--// 				}--%>
<%--			});--%>

			// AUIGrid
			createAUIGrid();
			fnInit();

		})

		function fnInit() {
			<%--if("${SecureUser.org_type}" == "AGENCY") {--%>
			if(${page.fnc.F00023_003 eq 'Y'}) {
				$("#_fnSms").addClass("dpn");
			}

			fnShowHideColumn();
		}

		function fnSms() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			 var param = {
			 			'sms_send_type_cd' : "2",
			   			'req_sendtarger_yn' : "Y"
			 }
			 openSendSmsPanel($M.toGetParam(param));
		}

		function reqSendTargetList(){
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			var parentTargetList = [];
			for (var i = 0; i < items.length; i++) {
				var obj = new Object();

				obj['phone_no'] = items[i].origin_hp_no;
				obj['receiver_name'] = items[i].origin_cust_name;
				obj['ref_key'] = items[i].cust_no;

				parentTargetList.push(obj);
			}
	 		return parentTargetList;
		}

		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "고객조회/등록", exportProps);
		}

		// 신규
		function goNew() {
			$M.goNextPage("/cust/cust010201");
		}

		// 조회
		function goSearch() {
			if($M.getValue("s_cust_name") == "" && $M.getValue("s_breg_name") == "" && $M.getValue("s_breg_no") == "" && $M.getValue("s_hp_no") == "" && $M.getValue("s_tel_no") == ""
					&& $M.getValue("s_body_no") == "" && $M.getValue("s_machine_name") == "" && $M.getValue("s_maker_cd_str") == ""
					&& $M.getValue("s_cust_breg_name") == "" && $M.getValue("s_center_org_code") == ""
					&& ($M.getValue("s_sale_start_dt") == "" && $M.getValue("s_sale_end_dt") == "")) {
				alert("검색조건 중 하나는 필수입니다.");
				return false;
			}
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				fnShowHideColumn();
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

		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
					"s_sale_start_dt" : $M.getValue("s_sale_start_dt"),
					"s_sale_end_dt" : $M.getValue("s_sale_end_dt"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_hp_no" : $M.getValue("s_hp_no"),
					"s_body_no" : $M.getValue("s_body_no"),
					"s_breg_no" : $M.getValue("s_breg_no"),
					"s_tel_no" : $M.getValue("s_tel_no"),
					"s_breg_name" : $M.getValue("s_breg_name"),
					"s_cust_breg_name" : $M.getValue("s_cust_breg_name"),
					"s_machine_name" : $M.getValue("s_machine_name"),
// 					"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq"),
					"s_machine_plant_seq_str" : $M.getArrStr(machinePlantSeqArr, {isEmpty : true}),
					"s_maker_cd_str" : $M.getValue("s_maker_cd_str"),
					"s_center_org_code" : $M.getValue("s_center_org_code"),
					"s_machine_yn" : $M.getValue("s_machine_yn") == "Y" ? "Y" : "N",
					"s_history_yn" : $M.getValue("s_history_yn") == "Y" ? "Y" : "N",
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
					<%--"s_use_yn" : ${SecureUser.org_code != '2000'} ? "Y" : $M.getValue("s_use_yn"),--%>
					"s_use_yn" : ${page.fnc.F00023_001 ne 'Y'} ? "Y" : $M.getValue("s_use_yn"),
					"page" : page,
					"rows" : $M.getValue("s_rows"),
// 					"s_search_dt_type_cd" : $M.getValue("s_search_dt_type_cd"),
// 					"this_page" : this_page,
					"s_sale_area_code" : '', // 지역 필터링,
					"s_cust_sale_type_cd" : $M.getValue("s_cust_sale_type_cd"), // 고객분류2
					"s_main_mng_yn" : $M.getValue("s_main_mng_yn") // 주요관리업체여부
			};
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

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
					}
				}
			);
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			}
		}

		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
			});
		}

		function enter(fieldObj) {
			var field = ["s_cust_name", "s_hp_no", "s_body_no", "s_breg_name", "s_breg_no", "s_tel_no", "s_cust_breg_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

		// 멀티셀렉트 토글
	// 	function fnSelectToggle() {
	// 		$(".multiselect").toggleClass("dpn");
	// 	}

		// 검색필터
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
				rowIdField : "_$uid",
				usePaging : false,
				showRowCheckColumn : true,
				headerHeight : 40,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 4,
				height : 565,
				rowStyleFunction: function (rowIndex, item) {
					if(item.red_yn == "Y") {
						return "aui-color-red";
					}
					return "";
				}
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "130",
					minWidth : "120",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						<%--if("${SecureUser.org_type}" == "AGENCY" && value == $M.getValue("s_cust_name") && item.hp_no.replaceAll('-', '') == $M.getValue("s_hp_no").replaceAll('-', '')) {--%>
						if(${page.fnc.F00023_003 eq 'Y'} && (value == $M.getValue("s_cust_name") || value == $M.getValue("s_cust_breg_name")) && item.hp_no.replaceAll('-', '') == $M.getValue("s_hp_no").replaceAll('-', '')) {
							return "aui-popup";
						<%--} else if ("${SecureUser.org_type}" != "AGENCY"){--%>
						} else if (${page.fnc.F00023_003 ne 'Y'}){
							return "aui-popup";
						} else {
							return "aui-center";
						}
					},
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "115",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "115",
					minWidth : "110",
					style : "aui-left",
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "150",
					minWidth : "145",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						<%--if("${SecureUser.org_type}" != "AGENCY" && $M.getValue("s_machine_yn") == "Y") {--%>
						if(${page.fnc.F00023_003 ne 'Y'} && $M.getValue("s_machine_yn") == "Y") {
							return "aui-popup aui-left";
						} else {
							return "aui-left";
						}
					},
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
							if (item["mch_type"] == "E") {
								machineYn = "보유(임의)";
							} else {
								machineYn = "보유";
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
				},
				{
					headerText : "판매일자",
					dataField : "sale_dt", // 판매일자 컬럼명 확인필요
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					dataType : "date",
					style : "aui-center",
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
					headerText : "차주변경일",
					dataField : "change_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "100",
					minWidth : "50",
					style : "aui-center",
				},
				{
					headerText : "장비상태",
					dataField : "curr_status_name",
					width : "80",
					minWidth : "50",
					style : "aui-center",
				},
				{
					headerText : "업체명",
					dataField : "breg_name",
					width : "130",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "전화번호",
					dataField : "tel_no",
					width : "105",
					minWidth : "105",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     if(String(value).length > 0) {
					         // 전화번호에 대시 붙이는 정규식으로 표현
					         return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/,"$1-$2-$3");
					     }
					     return value;
					}
				},
				{
					headerText : "사업자번호",
					dataField : "breg_no",
					width : "110",
					minWidth : "105",
					style : "aui-center",
				},
				{
					headerText : "주소",
					dataField : "addr",
					width : "185",
					minWidth : "180",
					style : "aui-left",
				},
				{
					headerText : "담당센터",
					dataField : "center_org_name",
					width : "75",
					minWidth : "70",
					style : "aui-center",
				},
				{
					headerText : "서비스담당",
					dataField : "service_mem_name",
					headerStyle : "aui-fold",
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "수주",
					dataField : "part_sale_no",
					headerStyle : "aui-fold",
					width : "95",
					minWidth : "90",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var no = value;
						return no.substring(4, 12);
					}
				},
				{
					headerText : "정비",
					dataField : "job_report_no",
					headerStyle : "aui-fold",
					width : "95",
					minWidth : "90",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var no = value;
						return no.substring(4, 16);
					}
				},
				{
					headerText : "회원구분", // 회원 타입(정회원,준회원,비회원)임.
					dataField : "cust_type_name",
					width : "70",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "구분", // 고객분류2(고객판매타입)
					dataField : "cust_sale_type_name",
					width : "70",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width: "70",
					minWidth: "60",
					style : "aui-center",
					<%--visible : "${SecureUser.org_code}" == "2000",--%>
					visible : ${page.fnc.F00023_001 eq 'Y'},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item["use_yn"] == "Y" ? "사용" : "미사용";
					}
				},
				{
					headerText : "장비용도",
					dataField : "mch_use_str",
					headerStyle : "aui-fold",
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "마케팅구분",
					dataField : "sale_type_ca",
					headerStyle : "aui-fold",
					width : "70",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == ""? "" : (value == "C" ? "건설기계" : "농기계");
					},
				},
				{
					headerText : "구매구분",
					dataField : "sale_gubun",
					headerStyle : "aui-fold",
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					headerStyle : "aui-fold",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					dataType : "numeric",
					formatString: "#,###",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value != "" && value > 0) {
							return AUIGrid.formatNumber(value, "#,###") + " h";
						} else {
							return "";
						}
					}
				},
				{
					headerText : "생년월일",
					dataField: "birth_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					headerStyle : "aui-fold",
					width: "95",
					minWidth: "95",
					style: "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value != "") {
							if (item["solar_cal_yn"] != "Y") {
								return AUIGrid.formatDate(value, "yyyy-mm-dd") + "(음)";
							} else {
								return AUIGrid.formatDate(value, "yyyy-mm-dd");
							}
						}
					},
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
					dataField : "cust_type_cd",
					visible : false
				},
				{
					headerText : "개인정보<br\>수집동의",
					dataField : "personal_yn",
					headerStyle : "aui-fold",
					width : "60",
					minWidth : "50",
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) {
						return value == "Y" ? value : "N";
					}
				},
				{
					headerText : "제3자<br\>제공동의",
					dataField : "three_yn",
					headerStyle : "aui-fold",
					width : "60",
					minWidth : "50",
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) {
						return value == "Y" ? value : "N";
					}
				},
				{
					headerText : "마케팅<br\>이용동의",
					dataField : "marketing_yn",
					headerStyle : "aui-fold",
					width : "60",
					minWidth : "50",
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) {
						return value == "Y" ? value : "N";
					}
				},
				{
					headerText : "앱사용여부",
					dataField : "app_use_yn",
					width : "80",
					minWidth : "60",
					style : "aui-center"
				},
				{
					dataField : "origin_hp_no",
					visible : false
				},
				{
					dataField : "origin_cust_name",
					visible : false
				},
				{
					dataField : "machine_seq",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 		AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'cust_name'){
					<%--if("${SecureUser.org_type}" != "AGENCY" || ("${SecureUser.org_type}" == "AGENCY" && event.item["cust_name"] == $M.getValue("s_cust_name") && event.item["hp_no"].replaceAll('-', '') == $M.getValue("s_hp_no").replaceAll('-', ''))) {--%>
					if(${page.fnc.F00023_003 ne 'Y'} || (${page.fnc.F00023_003 eq 'Y'} && (event.item["cust_name"] == $M.getValue("s_cust_name") || event.item["cust_name"] == $M.getValue("s_cust_breg_name")) && event.item["hp_no"].replaceAll('-', '') == $M.getValue("s_hp_no").replaceAll('-', ''))) {
						var param = {
								cust_no : event.item["cust_no"]
							};
						if($M.getValue("s_machine_yn") == "Y") {
							param.machine_seq = event.item["machine_seq"];
						}

						var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
						$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
					}
				} else if(event.dataField == 'body_no'){
					if (event.item["body_no"] != "") {
						<%--if("${SecureUser.org_type}" != "AGENCY" && $M.getValue("s_machine_yn") == "Y") {--%>
						if( ${page.fnc.F00023_003 ne 'Y'} && $M.getValue("s_machine_yn") == "Y") {
							var param = {
								s_machine_seq : event.item["machine_seq"]
							};

							var poppupOption = "";
							$M.goNextPage('/sale/sale0205p01', $M.toGetParam(param), {popupStatus : poppupOption});
						}
					}
				} else if (event.dataField == "machine_yn" && event.item["machine_yn"] == "Y") {
					var param = {
						"cust_no": event.item["cust_no"]
					}
					$M.goNextPage('/comp/comp0308', $M.toGetParam(param), {popupStatus : ""});
				}
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			AUIGrid.hideColumnByDataField(auiGrid, dataField);
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

			// 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);

		}

// 		// 컬럼 숨기기
// 		function fnChangeColumn(event) {
// 			var data = AUIGrid.getGridData(auiGrid);
// 			var target = event.target || event.srcElement;
// 			if(!target)	return;

// 			var checked = target.checked;

// 			if(checked) {
// 				AUIGrid.hideColumnByDataField(auiGrid, dataField);
// 				$("#label_name").text("펼치기");
// 			} else {
// 				AUIGrid.showColumnByDataField(auiGrid, dataField);
// 				$("#label_name").text("접기");
// 			}

//  		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
// 		}


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

 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}

		// (2021-07-15 (SR:11316) 모델 다중 조회 추가 - 황빛찬)
		function setModelInfo(data) {
			var machineName = data[0].machine_name;
			var machineCnt = data.length - 1;

			if (data.length > 1) {
				machineName += " 외" + machineCnt + "건";
			}

			$M.setValue("s_machine_name", machineName);

			machinePlantSeqArr = [];
			for (var i = 0; i < data.length; i++) {
				machinePlantSeqArr.push(data[i].machine_plant_seq);
			}
		}

		// 연식, 차주변경일, 장비상태 컬럼 노출여부 체크
		function fnShowHideColumn() {
			if ($M.getValue("s_machine_yn") != "Y") {
				AUIGrid.hideColumnByDataField(auiGrid, "made_year");
				AUIGrid.hideColumnByDataField(auiGrid, ["change_dt", "curr_status_name"]);
			} else {
				AUIGrid.showColumnByDataField(auiGrid, "made_year");
				if ($M.getValue("s_history_yn") != "Y") {
					AUIGrid.hideColumnByDataField(auiGrid, ["change_dt", "curr_status_name"]);
				} else {
					AUIGrid.showColumnByDataField(auiGrid, ["change_dt", "curr_status_name"]);
				}
			}
		}
	</script>
<!-- /script -->
<body>
<form name="main_form" id="main_form">
<input type="hidden" id="s_machine_plant_seq" name="s_machine_plant_seq">
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
		<div class="search-wrap pr" style="padding:10px;">
    <%--  q&a - 17566 고객조회/등록 + 기호 삭제, 모든 조건 노출로 변경   --%>
<%--			<div class="triangle-down-right">--%>
<%--        <i class="icon-btn-triangle-down"></i>--%>
<%--      </div> --%>
				<table class="table">
					<colgroup>
						<col width="55px">
						<col width="95px">
						<col width="55px">
						<col width="95px">
						<col width="70px">
						<col width="95px">
						<col width="55px">
						<col width="100px">
						<col width="65px">
						<col width="100px">
						<col width="65x">
						<col width="155px">
						<col width="50px">
						<col width="140px">
						<col width="100px">
						<col width="110px">
<%--						<c:if test="${SecureUser.org_code == '2000'}">--%>
						<c:if test="${page.fnc.F00023_001 eq 'Y'}">
						<col width="55px">
						<col width="80px">
						</c:if>
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th>고객명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_cust_name" name="s_cust_name" alt="고객명">

								</div>
							</td>
							<th>업체명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_breg_name" name="s_breg_name">
								</div>
							</td>
							<th>사업자번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" placeholder="-없이 숫자만" id="s_breg_no" name="s_breg_no">

								</div>
							<th>휴대폰</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" placeholder="-없이 숫자만" id="s_hp_no" name="s_hp_no" alt="휴대폰">

								</div>
							</td>
							<th>전화번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" placeholder="-없이 숫자만" id="s_tel_no" name="s_tel_no"  alt="전화번호">

								</div>
							</td>
							<th>차대번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" placeholder="-없이 숫자만" id="s_body_no" name="s_body_no"  alt="차대번호">

								</div>
							</td>
							<th>모델</th>
							<td>
								<div class="form-row inline-pd pl5">
<!-- 								(2021-07-15 (SR:11316) 모델 다중 조회 추가 - 황빛찬) -->
										<div class="input-group width120px">
											<input type="text" id="s_machine_name" name="s_machine_name" class="form-control border-right-0" readonly>
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('setModelInfo', 'Y');"><i class="material-iconssearch"></i></button>
										</div>
<%-- 									<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp"> --%>
<%-- 			                     		<jsp:param name="required_field" value=""/> --%>
<%-- 			                     		<jsp:param name="s_maker_cd" value=""/> --%>
<%-- 			                     		<jsp:param name="s_machine_type_cd" value=""/> --%>
<%-- 			                     		<jsp:param name="s_sale_yn" value=""/> --%>
<%-- 			                     		<jsp:param name="readonly_field" value=""/> --%>
<%-- 			                     		<jsp:param name="execFuncName" value=""/> --%>
<%-- 			                     		<jsp:param name="focusInFuncName" value=""/> --%>
<%-- 			                     	</jsp:include> --%>
								</div>
							</td>
							<th>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_machine_yn" name="s_machine_yn"
<%--										<c:if test="${SecureUser.org_type ne 'BASE' || SecureUser.org_code.substring(0, 1) eq '5' || SecureUser.org_code.substring(0, 1) eq '8'}"> checked="checked"	</c:if> value="Y">--%>
										<c:if test="${page.fnc.F00023_002 eq 'Y'}"> checked="checked"	</c:if> value="Y">
									<label class="form-check-label mr5" for="s_machine_yn">보유기종별</label>
								</div>
							</th>
							<th>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_history_yn" name="s_history_yn" value="Y">
									<label class="form-check-label mr5" for="s_history_yn">과거자료확인</label>
								</div>
							</th>
							<c:if test="${page.fnc.F00023_001 eq 'Y'}">
							<th>사용여부</th>
							<td>
								<select class="form-control" id="s_use_yn" name="s_use_yn">
									<option value="">- 전체 -</option>
									<option value="Y" selected="selected">사용</option>
									<option value="N">미사용</option>
								</select>
							</td>
							</c:if>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
							</td>
						</tr>
					</tbody>
				</table>
				<!-- 검색조회 펼침 -->
				<div class="search-expand"> <!-- dpn으로 껐다 켰다 조절 -->
					<table class="table">
						<colgroup>
							<!-- 메이커 -->
							<col width="50px">
							<col width="255px">
							<!-- 판매일자 -->
							<col width="65px">
							<col width="250px">
							<!-- 담당센터 -->
							<col width="65px">
							<col width="70px">
							<!-- 고객+ 업체명 -->
							<col width="95px">
							<col width="95px">
							<!-- 구분(고객분류2) -->
							<col width="50px">
							<col width="140px">
							<!-- 주요업체관리 -->
							<col width="110px">
							<!-- 지역필터 -->
							<col width="">
							<col width="100px">
						</colgroup>
						<tbody>
							<tr>
								<th>메이커</th>
								<td>
									<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd_str" name="s_maker_cd_str" easyui="combogrid"
										   easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
								</td>
								<th>판매일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_sale_start_dt" name="s_sale_start_dt" alt="시작일" dateFormat="yyyy-MM-dd" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_sale_end_dt" name="s_sale_end_dt" alt="종료일" dateFormat="yyyy-MM-dd" value="">
											</div>
										</div>
<%-- 										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp"> --%>
<%-- 				                     		<jsp:param name="st_field_name" value="s_sale_start_dt"/> --%>
<%-- 				                     		<jsp:param name="ed_field_name" value="s_sale_end_dt"/> --%>
<%-- 				                     		<jsp:param name="click_exec_yn" value="N"/> --%>
<%-- 				                     		<jsp:param name="exec_func_name" value="goSearch();"/> --%>
<%-- 				                     	</jsp:include>									 --%>
									</div>
								</td>
								<th>담당센터</th>
								<td>
									<select class="form-control" style="width:95px;" id="s_center_org_code" name="s_center_org_code" >
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>고객명+업체명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_cust_breg_name" name="s_cust_breg_name" style="width:122px">
									</div>
								</td>
								<th>구분</th>
								<td>
									<select class="form-control" style="width:99px;" id="s_cust_sale_type_cd" name="s_cust_sale_type_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${cust_sale_type_list}">
											<option value="${item.code}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_main_mng_yn" name="s_main_mng_yn" value="Y">
										<label class="form-check-label mr5" for="s_main_mng_yn">주요관리업체</label>
									</div>
								</th>
								<th>지역 필터</th>
								<td class="pl5">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_place_filter_yn" name="s_place_filter_yn" value="Y" onclick="javascript:showPlaceFilter();">
										<label class="form-check-input" for="s_place_filter_yn">지역 필터</label>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색조회 펼침 -->
			</div>
			<!-- /검색영역 -->
			<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="row">
				<div id="palce_area_filter" class="col-2" style="display: none">
					<div id="auiGridArea" style="margin-top: 1px; height: 630px;"></div>
				</div>
				<div id="result_area" class="col-12"> <!-- 결과물 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<div class="text-warning ml5">
								※ 보유기종별 체크 시 차대번호별 고객 조회가 가능합니다.
								</div>
								<div class="form-check form-check-inline">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</c:if>

									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
		</div>
	</div>
	<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>
