<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > CYCLE CHECK > null > CYCLE CHECK 품의서 상세
-- 작성자 : 성현우.
-- 최초 작성일 : 2020-03-20 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
	<style type="text/css">
	
		/* 커스텀 행 스타일 (차이수량 마이너스) */
		.my-row-style1 {
			color:red; 
			background: #fdf0e5;
		}
	
		/* 커스텀 행 스타일 차이수량 플러스) */
		.my-row-style2 {
			color:green;
			background: #dbead5;
		}
			
		/* 커스텀 행 스타일 (차이수량 마이너스 합) */
		.my-row-style3 {
			color:red; 
		}
	
		/* 커스텀 행 스타일 법인카드(차이수량 플러스 합) */
		.my-row-style4 {
			color:green;
		}	
							
	</style>
	
	<script type="text/javascript">

	var partCnt = 0;
	var partName;
	
	var auiGrid;
	var auiGridDiff;
	var apprStatus = "${apprBean.appr_proc_status_cd}"; // 결재상태 01:작성중  02:결재요청  03:결재중  04:반려  05:완료
	
	$(document).ready(function() {
		
		createAUIGrid();
		createAUIGridDiff();
		
		fnInit();
		
		//달력이 바뀌기전 이전 값을 저장하기
		$('#check_st_dt,#check_ed_dt').on('focusin', function(){
		    //console.log("Saving value " + $(this).val());
		    $(this).data('val', $(this).val());
		});

		//조사기간 변경시 확인 		
	 	var msg = "조사기간을 변경시 재고조사 결과값이 변경됩니다.\r 변경하시겠습니까?"
				 
		$('#check_st_dt').on('change', function(){
			
		    var prev = $(this).data('val');
		   	$M.setValue("last_check_st_dt",prev);

			if(confirm(msg)) {
				goSearch();
			}
			else{
				$("#check_st_dt").val(prev);
			}    
		});

		$('#check_ed_dt').on('change', function(){
			
	    	var prev = $(this).data('val');
		   	$M.setValue("last_check_ed_dt",prev);
		    
		    //console.log("Prev value " + prev);
		    //console.log("New value " + current);
		   
			if(confirm(msg)) {
				goSearch();
			}
			else{
				$("#check_ed_dt").val(prev);
			}			
		});
		
		$("#btnHideTop").children().eq(0).attr('id','btnPartList');
		$("#btnHideTop").children().eq(1).attr('id','btnDownLoadExcel');
		
	});

	
	function fnInit() {
		
		//결재완료이고 최종결재자가 보는 화면인 경우 전산반영요청 버튼 활성화
		if(apprStatus == "05" ){
			
			$("#btnHideBottom").children().eq(0).attr('id','btnPartAdjustRequest');
			
			// Q&A 12075 파트장님 추가요청 210727 김상덕
			if( 
				('${apprBean.appr_mem_no}' == '${SecureUser.mem_no}' || '${page.fnc.F00444_001}' == 'Y')
				&& "${cycle.adjust_yn}" == "N"
			){

				$("#btnPartAdjustRequest").css({
		            display: ""
		        });
				
			}
			else{
				$("#btnPartAdjustRequest").css({
		            display: "none"
		        });
			}
		}		
	}
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			wrapSelectionMove : false,
			showRowNumColumn : true,			
			// row Styling 함수
			rowStyleFunction : function(rowIndex, item) {				
				
				if(item.diff_cnt < 0) {
					return "my-row-style1";
				}
				
				if(item.diff_cnt > 0 ) {
					return "my-row-style2";
				}
			
			},			
			showFooter : true,
			footerPosition : "top",
			editableOnFixedCell : true,
			editable : false
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				width : "10%",
				style : "aui-center  aui-popup"
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				width : "10%",
				style : "aui-left"
			},
			{
				dataField : "part_check_stock_seq",
				visible : false
			},
			{
				dataField : "part_storage_seq",
				visible : false
			},
			{
				headerText : "저장위치",
				dataField : "storage_name",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "소비자가",
				dataField : "sale_price",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "센터재고",
				dataField : "current_stock",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "적정재고",
				dataField : "safe_stock",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "과부족",
				dataField : "overunder_cnt",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "조사일자",
				dataField : "stock_dt",
				dataType : "date",
				formatString : "yyyy-mm-dd", 
				width : "9%",
				style : "aui-center"
			},
			{
				headerText : "조사수량",
				dataField : "check_stock",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "차이수량",
				dataField : "diff_cnt",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "총조사금액",
				dataField : "sale_amt",
				width : "7%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "과다금액",
				dataField : "over_amt",
				width : "7%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "부족금액",
				dataField : "under_amt",
				width : "7%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "과부족금액",
				dataField : "diff_amt",				
				visible : false
			},
			{
				headerText : "조정완료",
				dataField : "adjust_id",
				width : "6%",
				style : "aui-left"
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "9%",
				style : "aui-left"
			},
			
		]

		// 푸터레이아웃
		var footerColumnLayout = [ 
			{
				labelText : "과다금액",
				positionField : "part_no",
				colSpan : 4,
				style : "aui-center aui-footer my-row-style4"
			}, 
			{
				dataField : "over_amt",
				positionField : "sale_price",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer  my-row-style4"
			},
			{
				labelText : "부족금액",
				positionField : "current_stock",
				colSpan : 3,
				style : "aui-center aui-footer  my-row-style3"
			},				
			{
				dataField : "under_amt",
				positionField : "stock_dt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer  my-row-style3"
			}
			,
			{
				labelText : "차이금액 합계",
				positionField : "check_stock",
				colSpan : 3,
				style : "aui-center aui-footer"
			},				
			{
				dataField : "diff_amt",
				positionField : "over_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			}
		];
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid,  ${listDtl});
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
		AUIGrid.resize(auiGrid);
		
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if (event.dataField == "part_no") {
				// Row행 클릭 시 반영
				
				var param = {
 						s_warehouse_cd 	: "${inputParam.s_warehouse_cd}",
 						s_part_no 		: event.item.part_no,
 						s_stock_yn       : "A"
 	
 					};
				var popupOption = "";
				
				$M.goNextPage("/part/part0501p01", $M.toGetParam(param), {popupStatus : popupOption});	
			}
		});
		
		
	}
	
	function createAUIGridDiff() {
		var gridPros = {
			rowIdField : "_$uid",
			wrapSelectionMove : false,
			showRowNumColumn : true,			
			// row Styling 함수
			rowStyleFunction : function(rowIndex, item) {				
				
				if(item.diff_cnt < 0) {
					return "my-row-style1";
				}
				
				if(item.diff_cnt > 0 ) {
					return "my-row-style2";
				}
			
			},			
			showFooter : true,
			footerPosition : "top",
			editableOnFixedCell : true,
			editable : false
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				width : "10%",
				style : "aui-center  aui-popup"
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				width : "10%",
				style : "aui-left"
			},
			{
				dataField : "part_check_stock_seq",
				visible : false
			},
			{
				dataField : "part_storage_seq",
				visible : false
			},
			{
				headerText : "저장위치",
				dataField : "storage_name",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "소비자가",
				dataField : "sale_price",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "센터재고",
				dataField : "current_stock",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "적정재고",
				dataField : "safe_stock",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "과부족",
				dataField : "overunder_cnt",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "조사일자",
				dataField : "stock_dt",
				dataType : "date",
				formatString : "yyyy-mm-dd", 
				width : "9%",
				style : "aui-center"
			},
			{
				headerText : "조사수량",
				dataField : "check_stock",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "차이수량",
				dataField : "diff_cnt",
				width : "5%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-center"
			},
			{
				headerText : "총조사금액",
				dataField : "sale_amt",
				width : "7%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "과다금액",
				dataField : "over_amt",
				width : "7%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "부족금액",
				dataField : "under_amt",
				width : "7%",
			 	dataType : "numeric",
			 	formatString : "#,##0",
				style : "aui-right"
			},
			{
				headerText : "과부족금액",
				dataField : "diff_amt",				
				visible : false
			},
			{
				headerText : "조정완료",
				dataField : "adjust_id",
				width : "6%",
				style : "aui-left"
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "9%",
				style : "aui-left"
			},
			
		]

		// 푸터레이아웃
		var footerColumnLayout = [ 
			{
				labelText : "과다금액",
				positionField : "part_no",
				colSpan : 4,
				style : "aui-center aui-footer my-row-style4"
			}, 
			{
				dataField : "over_amt",
				positionField : "sale_price",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer  my-row-style4"
			},
			{
				labelText : "부족금액",
				positionField : "current_stock",
				colSpan : 3,
				style : "aui-center aui-footer  my-row-style3"
			},				
			{
				dataField : "under_amt",
				positionField : "stock_dt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer  my-row-style3"
			}
			,
			{
				labelText : "차이금액 합계",
				positionField : "check_stock",
				colSpan : 3,
				style : "aui-center aui-footer"
			},				
			{
				dataField : "diff_amt",
				positionField : "over_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			}
		];
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGridDiff = AUIGrid.create("#auiGridDiff", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridDiff,  ${listDiffDtl});
		AUIGrid.setFooter(auiGridDiff, footerColumnLayout);
		AUIGrid.resize(auiGridDiff);
		
		
		AUIGrid.bind(auiGridDiff, "cellClick", function(event) {
			if (event.dataField == "part_no") {
				// Row행 클릭 시 반영
				
				var param = {
 						s_warehouse_cd 	: "${inputParam.s_warehouse_cd}",
 						s_part_no 		: event.item.part_no,
 						s_stock_yn       : "A"
 					};
				var popupOption = "";
				
				$M.goNextPage("/part/part0501p01", $M.toGetParam(param), {popupStatus : popupOption});	
			}
		});
		
		
	}
	
	
	
	function goSearch() {
		
		var param = {
			s_warehouse_cd 	  	: "${ cycle.warehouse_cd }",
			s_start_dt  		:  $M.getValue("check_st_dt"),
			s_end_dt  			:  $M.getValue("check_ed_dt"),
			s_only_diff_yn 		:  $M.getValue("only_diff_yn"),
			cycle_check_no		:  $M.getValue("cycle_check_no")
		};
		
		
		var searchUrl = "";
		
		//작성중이면 재고실사에서 다시 조회 
		//결재요청 이상이면 CYCLE_CHECK 저장된 정보만 조회
		if($M.getValue("appr_proc_status_cd") == '01' ) {
			searchUrl = "/part/part050401";
		}
		else {
			searchUrl = "/part/part0504p01";
		}
		
		
		
		
		$M.goNextPageAjax(searchUrl + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
										
					$("#total_cnt").html(result.total_cnt );
					
					 AUIGrid.setGridData(auiGrid, result.listDtl);
					 AUIGrid.setGridData(auiGridDiff, result.listDiffDtl);
					 
					 if ($M.getValue("only_diff_yn") == "Y"){							 						 
					
						 $("#auiGrid").hide();
						 $("#auiGridDiff").show(); 
						 AUIGrid.resize(auiGrid);
						 AUIGrid.resize(auiGridDiff);
					 } 
					 else {
						
						$("#auiGrid").show();
						$("#auiGridDiff").hide(); 
						AUIGrid.resize(auiGrid);
						AUIGrid.resize(auiGridDiff);
					 }


					$M.setValue("check_total_amt" , result.cycle.check_total_amt );				
					$M.setValue("diff_total_amt" , result.cycle.diff_total_amt );					
					$M.setValue("adjust_total_amt" , result.cycle.adjust_total_amt );
					$M.setValue("diff_total_cnt" , result.cycle.diff_total_cnt );				
					$M.setValue("check_total_cnt" , result.cycle.check_total_cnt );					
					$M.setValue("adjust_total_cnt" , result.cycle.adjust_total_cnt );
					$M.setValue("check_rate" , result.cycle.check_rate );					

					$("#sp_diff_total_cnt").text(result.cycle.diff_total_cnt );
					$("#sp_check_total_cnt").text(result.cycle.check_total_cnt);
					$("#sp_adjust_total_cnt").text(result.cycle.adjust_total_cnt);
					
					//결재완료이고 최종결재자가 보는 화면인 경우 전산반영요청 버튼 활성화
					if(apprStatus == "05" ){
											
						// Q&A 12075 파트장님 추가요청 210727 김상덕
						if(
							('${apprBean.appr_mem_no}' == '${SecureUser.mem_no}' || '${page.fnc.F00441_001}' == 'Y')
							&& "${cycle.adjust_yn}" == "N"
						){

							$("#btnPartAdjustRequest").css({
					            display: ""
					        });
							
						}
						else{
							$("#btnPartAdjustRequest").css({
					            display: "none"
					        });
						}
					}
					
					var btnHtml = $("#btnPartList").html();		
					btnHtml = $M.getValue("only_diff_yn") == "Y" ? btnHtml.replace("과부족 발생수량만 보기" , "전체보기") : btnHtml.replace("전체보기" , "과부족 발생수량만 보기");
						
					$("#btnPartList").html(btnHtml);
				};
			}
		);
	}
	
	
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "CYCLE_CHECK 상세");
	}

	function goPartList() {
		
		$M.setValue("only_diff_yn",   $M.getValue("only_diff_yn") == "Y" ? "N" : "Y" );
		goSearch();
	}
	
	// 상신취소
	function goApprCancel() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			appr_cancel_yn : "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}
	
	// 결재처리 결과
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method : 'GET'},
				function(result) {
			    	if(result.success) {
			    		alert("결재취소가 완료됐습니다.");	
			    		location.reload();
					}
				}
			);
	}


	// 결재처리
	function goApproval() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}"
		};
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}
	
	// 결재처리 결과
	function goApprovalResult(result) {
		console.log(result);
		// 반려이면 페이지 리로딩
		if(result.appr_status_cd == '03') {
			alert("반려가 완료되었습니다.");
			location.reload();
		}
		else{
			alert("처리가 완료되었습니다.");	
    		location.reload();
		}
	}
	
	//결재요청버튼
	function goRequestApproval() {
		goSave('appr');
	}
	
	
	// 수정버튼
	function goModify() {
		goSave();
	}
	
	function goSave(appr) {
		
		var msg = appr == "appr" ? "결재요청하시겠습니까?" : "수정하시겠습니까?";		
		var cycleCheckNo = $M.getValue("cycle_check_no");
		
		appr = appr == undefined ? "modify" : appr;
		$M.setValue("save_mode", appr);
		
		
		var frm = document.main_form;

	     // validation check
     	if($M.validation(frm) == false) {
     		return;
     	}
	     
    	if($M.checkRangeByFieldName("check_st_dt", "check_ed_dt", true) == false) {				
			return;
		};  
			
     	//사이클체크 상세내역 배열로 만들어서 넘기기 ( 그리드 ) 	
		var partNoArr = [];
		var partCheckStockSeqArr = [];
		var salePriceArr = [];
		var currentStockArr = [];
		var checkStockArr = [];
		var safeStockArr = [];
		var diffCntArr = [];
		var saleAmtArr = [];
		var diffAmtArr = [];
		var remarkArr = [];	
		var cmdArr = [];

		var partName;
		
		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList = AUIGrid.getOrgGridData(auiGrid);
		
		if(gridAllList.length < 1 ){
			alert("저장할 데이터가 없습니다.")
			return;
		}
		
		for (var i = 0; i < gridAllList.length; i++) {
					
			if( i == 0){
				partName = gridAllList[i].part_name
			}
			

			partNoArr.push(gridAllList[i].part_no);
			partCheckStockSeqArr.push(gridAllList[i].part_check_stock_seq);
			salePriceArr.push(gridAllList[i].sale_price);
			currentStockArr.push(gridAllList[i].current_stock);
			checkStockArr.push(gridAllList[i].check_stock);
			safeStockArr.push(gridAllList[i].safe_stock);
			diffCntArr.push(gridAllList[i].diff_cnt);		
			saleAmtArr.push(gridAllList[i].sale_amt);
			diffAmtArr.push(gridAllList[i].diff_amt);
			remarkArr.push(gridAllList[i].remark);		
			cmdArr.push("C");
	
			partCnt++;
		}

		
		var option = {
				isEmpty : true
		};
		
		var param = {
								
				//사이클체크 마스터 세팅		
				cycle_check_no  : 	$M.getValue("cycle_check_no"),			
				check_mon 		: 	$M.getValue("check_mon"),
				warehouse_cd 	: $M.getValue("warehouse_cd"),
				remark_master 	: $M.getValue("remark_master"),
				count_remark 	: partName + " 외 " + partCnt + "건",
				check_st_dt 	: $M.getValue("check_st_dt"),
				check_ed_dt 	: $M.getValue("check_ed_dt"),
				
				check_total_amt : $M.getValue("check_total_amt"),
				check_total_cnt : $M.getValue("check_total_cnt"),
				diff_total_amt 	: $M.getValue("diff_total_amt"),
				diff_total_cnt 	: $M.getValue("diff_total_cnt"),
				adjust_total_amt : $M.getValue("adjust_total_amt"),
				adjust_total_cnt : $M.getValue("adjust_total_cnt"),
				check_rate : $M.getValue("check_rate"),
		

				part_no_str : $M.getArrStr(partNoArr, option),
				part_check_stock_seq_str : $M.getArrStr(partCheckStockSeqArr, option),
				sale_price_str : $M.getArrStr(salePriceArr, option),
				current_stock_str : $M.getArrStr(currentStockArr, option),
				check_stock_str : $M.getArrStr(checkStockArr, option), 
				safe_stock_str : $M.getArrStr(safeStockArr, option), 
				diff_cnt_str : $M.getArrStr(diffCntArr, option), 
				sale_amt_str : $M.getArrStr(saleAmtArr, option), 
				diff_amt_str : $M.getArrStr(diffAmtArr, option), 
				remark_str : $M.getArrStr(remarkArr, option), 
				cmd_str : $M.getArrStr(cmdArr, option),
				
				//결제선 가져오기
				appr_job_seq : $M.getValue("appr_job_seq"),
				appr_job_cd : $M.getValue("appr_job_cd"),
				appr_status_cd : $M.getValue("appr_status_cd"),
				appr_mem_no_str : $M.getValue("appr_mem_no_str"),
				save_mode : $M.getValue("save_mode")
			}
		
	
		$M.goNextPageAjaxMsg(msg, this_page+"/"+cycleCheckNo+"/modify", $M.toGetParam(param), {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("처리가 완료되었습니다.");
	    			location.reload();
				}
			}
		);
	}
	
	function goPartAdjustRequest(){
		
		var msg = "전산반영요청 하시겠습니까?";
		var cycleCheckNo = $M.getValue("cycle_check_no");
		
		
		//변경되는 재고 없으면 
		
		$M.goNextPageAjaxMsg(msg, this_page+"/"+cycleCheckNo+"/adjustRequest", "", {method : 'POST'},
				function(result) {
		    		if(result.success) {
// 		    			alert("전산반영 처리가 완료되었습니다.");
		    			location.reload();
					}
				}
			);
		
	}
	

	function goApprRequestCancel() {
		alert("결제취소");
	}	

	function goRemove() {
			
		var apprProcStatusCd 	= $M.nvl($M.getValue("appr_proc_status_cd"), "");

		if ( apprProcStatusCd != "01") {
			alert("작성중인 자료만 삭제가능합니다.");
			return false;
		};
			
		var cycleCheckNo = $M.getValue("cycle_check_no");
		
		$M.goNextPageAjaxRemove(this_page +"/"+ cycleCheckNo + "/remove", "", {method : 'POST'}, 
			function(result) {
				if(result.success) {
					alert("삭제에 성공했습니다.");
	    			fnClose();
				};
			}
		);
	}
	
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
	
		<input type="hidden" id="count_remark" 			name="count_remark" 			value="${cycle.count_remark}" >
		<input type="hidden" id="save_mode" 			name="save_mode"> 
		<input type="hidden" id="appr_job_seq" 			name="appr_job_seq" 		value="${cycle.appr_job_seq}">
		<input type="hidden" id="cycle_check_no" 		name="cycle_check_no" 			value="${cycle.cycle_check_no}">
		<input type="hidden" id="appr_proc_status_cd" 	name="appr_proc_status_cd" 		value="${cycle.status_cd}">
		<input type="hidden" id="warehouse_cd" 			name="warehouse_cd" 		value="${cycle.warehouse_cd}" >
		<input type="hidden" id="check_mon" 			name="check_mon" 			value="${cycle.check_mon}" >
		<input type="hidden" id="diff_total_cnt" 		name="diff_total_cnt" 		value="${cycle.diff_total_cnt}" >
		<input type="hidden" id="check_total_cnt" 		name="check_total_cnt" 		value="${cycle.check_total_cnt}" >
		<input type="hidden" id="adjust_total_cnt" 		name="adjust_total_cnt" 	value="${cycle.adjust_total_cnt}" >
		<input type="hidden" id="adjust_total_amt" 		name="adjust_total_amt" 	value="${cycle.adjust_total_amt}" >
		<input type="hidden" id="last_check_st_dt" 	 	name="last_check_st_dt"  	value="${cycle.check_st_dt}"	>
		<input type="hidden" id="last_check_ed_dt" 		name="last_check_ed_dt" 	value="${cycle.check_ed_dt}" >

		
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<!-- 기본 -->
		<div class="content-wrap">
			<div class="title-wrap half-print">
				<div class="doc-info" style="flex:1;">
					<h4 class="primary">CYCLE CHECK품의서 상세</h4>
					<div>
						<span class="condition-item">상태 : 
							<c:choose>
								<c:when test="${'01' eq cycle.status_cd }">작성중</c:when>
								<c:when test="${'03' eq cycle.status_cd }">결재중</c:when> 
								<c:when test="${'05' eq cycle.status_cd and cycle.adjust_req_yn eq 'N' and cycle.adjust_comp_yn eq 'N' }">결재완료</c:when>
								<c:when test="${'05' eq cycle.status_cd and cycle.adjust_req_yn eq 'Y' and cycle.adjust_comp_yn eq 'N' }">전산반영요청</c:when>
								<c:when test="${'05' eq cycle.status_cd and cycle.adjust_req_yn eq 'Y' and cycle.adjust_comp_yn eq 'Y' }">전산반영완료</c:when>
								<c:otherwise>작성중</c:otherwise>						
							</c:choose>
						</span>	
					</div>
				</div>
				<!-- 결제영역 -->
				<div style="width:40%; margin-left:10px">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
				<!-- /결제영역 -->
			</div>
			<!-- 폼테이블 -->
			<div>
				<table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">품의차수</th>
							<td>${fn:substring(cycle.check_mon, 0, 4)}년 ${fn:substring(cycle.check_mon, 4, 6)}월</td>
							<th class="text-right">품의번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control   width120px" value="${ cycle.cycle_check_no }" readonly="readonly" >
									</div>
	
								</div>
							</td>
							<th class="text-right">품의창고</th>
							<td>
								<input type="text" class="form-control   width120px" value="${ cycle.warehouse_name }" readonly="readonly" >
							</td>
							<th class="text-right">조사기간</th>
							<td>
								<div class="form-row inline-pd" style="width:265px;" >
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="check_st_dt" name="check_st_dt" dateformat="yyyy-MM-dd" alt="조회 시작일"  value="${cycle.check_st_dt}"  ${cycle.status_cd != '01' ? 'disabled' : '' } >
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="check_ed_dt" name="check_ed_dt" dateformat="yyyy-MM-dd" alt="조회 완료일"   value="${cycle.check_ed_dt}"  ${cycle.status_cd != '01' ? 'disabled' : '' } >
										</div>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">조사항목수</th>
							<td>
								<span class="font-14" id="sp_check_total_cnt" name="sp_check_total_cnt" >${cycle.check_total_cnt}</span>
								<span class="font-11 spacing-sm text-dark" >(재고조정 완료건 : <span id="sp_adjust_total_cnt" name="sp_adjust_total_cnt" >${cycle.adjust_total_cnt}</span> 건 포함)</span>
							</td>
							<th class="text-right">과부족발생</th>
							<td>
								<span class="font-14 text-secondary" id="sp_diff_total_cnt" name="sp_diff_total_cnt" >${cycle.diff_total_cnt}</span>
								<span class="font-11 spacing-sm text-dark">(재고조정 완료건 : <span id="sp_adjust_total_cnt"  name="sp_adjust_total_cnt" >${cycle.adjust_total_cnt}</span>건 포함)</span>
							</td>							
							<th class="text-right">조사총금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control text-right   width120px" id="check_total_amt" name="check_total_amt" value="${cycle.check_total_amt}"  format="decimal" readonly="readonly" >
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">조사차이금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control text-right   width120px" id="diff_total_amt" name="diff_total_amt" value="${cycle.diff_total_amt}"  format="decimal" readonly="readonly" >
									</div>
									<div class="col-1">원</div>
									<div class="col-2 text-right">백분율</div>
									<div class="col-3">
										<input type="text" class="form-control text-right" id="check_rate" name="check_rate" value="${cycle.check_rate}" readonly="readonly" >
									</div>
									<div class="col-1">%</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 100%;" id="remark_master" name="remark_master"   ${cycle.status_cd != '01' ? 'readonly' : '' } >${cycle.remark}</textarea>
							</td>
							
							<th class="text-right">결재자의견</th>
							<td colspan="3" class="v-align-top">
								<div>
									<c:if test="${apprMemoList != null && apprMemoList.size() != 0}">
										<div id="apprMemoList">
											<div class="title-wrap mt10">
												<h4>결재자의견</h4>									
											</div>
											<table class="table-border doc-table md-table" style="margin-top: 5px">
												<colgroup>
													<col width="40px">
													<col width="140px">
													<col width="55px">
													<col width="">
												</colgroup>
												<thead>
													<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
													<tr><th class="th" style="font-size: 12px !important">구분</th>
													<th class="th" style="font-size: 12px !important">결재일시</th>
													<th class="th" style="font-size: 12px !important">담당자</th>
													<th class="th" style="font-size: 12px !important">특이사항</th>
												</tr></thead>
												<tbody>
													<c:forEach var="list" items="${apprMemoList}">
														<tr>
															<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
															<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
															<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
															<td class="td" style="font-size: 12px !important">${list.memo }</td>
														</tr>
													</c:forEach>
												</tbody>
											</table>
										</div>
									</c:if>
								</div>							
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<!-- 재고조사결과 -->
			<div class="title-wrap mt10">
				<h4>재고조사결과</h4>	
				<div id="btnHideTop" >
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" class="mt10" style="margin-top: 5px; width: 100%;height: 400px;"></div>
			<div id="auiGridDiff" class="mt10" style="margin-top: 5px; width: 100%;height: 400px;display:none;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt" >0</strong>건
				</div>					
				<div class="right" id="btnHideBottom" >
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${cycle.reg_id}"/>
						<jsp:param name="appr_yn" value="Y"/>
					</jsp:include>
					
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
		<!-- /기본 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>