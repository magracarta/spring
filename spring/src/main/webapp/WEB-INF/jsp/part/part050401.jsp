<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > CYCLE CHECK > CYCLE CHECK 품의서등록 > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-08-05 18:36:42
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

	var auiGrid;
	var auiGridDiff;
	var partCnt = 0;
	
	$(document).ready(function() {
		createAUIGrid();
		createAUIGridDiff();	
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
		   	
			if( $M.getValue("check_st_dt") > $M.getValue("check_ed_dt")){					
				alert("조사기간을 다시 확인해주세요.");
				$("#check_st_dt").val(prev);
				return;
			}

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
			editable : false
			
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				width : "7%",
				style : "aui-center aui-popup"
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
				width : "7%",
				style : "aui-center"
			},
			{
				headerText : "소비자가",
				dataField : "sale_price",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-right"
			},
			{
				headerText : "센터재고",
				dataField : "current_stock",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "적정재고",
				dataField : "safe_stock",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "과부족",
				dataField : "overunder_cnt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "조사일자",
				dataField : "check_stock_dt",
				dataType : "date",
				formatString : "yyyy-mm-dd", 
				width : "8%",
				style : "aui-center"
			},
			{
				headerText : "조사수량",
				dataField : "check_stock",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "차이수량",
				dataField : "diff_cnt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "총조사금액",
				dataField : "sale_amt",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "8%",
				style : "aui-right"
			},
			{
				headerText : "과다금액",
				dataField : "over_amt",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "8%",
				style : "aui-right"
			},
			{
				headerText : "부족금액",
				dataField : "under_amt",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "8%",
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
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "10%",
				style : "aui-left"
			}			
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
				positionField : "check_stock_dt",
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
		AUIGrid.setGridData(auiGrid, ${listDtl});
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		
		$("#total_cnt").html(${total_cnt});
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
			editable : false
			
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				width : "7%",
				style : "aui-center aui-popup"
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
				width : "7%",
				style : "aui-center"
			},
			{
				headerText : "소비자가",
				dataField : "sale_price",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-right"
			},
			{
				headerText : "센터재고",
				dataField : "current_stock",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "적정재고",
				dataField : "safe_stock",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "과부족",
				dataField : "overunder_cnt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "조사일자",
				dataField : "check_stock_dt",
				dataType : "date",
				formatString : "yyyy-mm-dd", 
				width : "8%",
				style : "aui-center"
			},
			{
				headerText : "조사수량",
				dataField : "check_stock",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "차이수량",
				dataField : "diff_cnt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "총조사금액",
				dataField : "sale_amt",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "8%",
				style : "aui-right"
			},
			{
				headerText : "과다금액",
				dataField : "over_amt",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "8%",
				style : "aui-right"
			},
			{
				headerText : "부족금액",
				dataField : "under_amt",				
				dataType : "numeric",
				formatString : "#,##0",
				width : "8%",
				style : "aui-right"
			},
			{
				headerText : "과부족금액",
				dataField : "diff_amt",				
				visible : false
			},
			{
				headerText : "조정완료",
				dataField : "adjust_remark",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "10%",
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
				positionField : "check_stock_dt",
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
		AUIGrid.setGridData(auiGridDiff, ${listDiffDtl});
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
			s_warehouse_cd 	  	: "${inputParam.s_warehouse_cd}",
			s_start_dt  		:  $M.getValue("check_st_dt"),
			s_end_dt  			:  $M.getValue("check_ed_dt"),
			s_only_diff_yn 		:  $M.getValue("only_diff_yn")
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {							
					$("#total_cnt").html(result.total_cnt);
					
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
					$("#sp_adjust_total_cnt").text( result.cycle.adjust_total_cnt );
					$("#sp_adjust_total_cnt2").text( result.cycle.adjust_total_cnt );
					
					
					var btnHtml = $("#btnPartList").html();		
					btnHtml = $M.getValue("only_diff_yn") == "Y" ? btnHtml.replace("과부족 발생수량만 보기" , "전체보기") : btnHtml.replace("전체보기" , "과부족 발생수량만 보기");
						
					$("#btnPartList").html(btnHtml);					
				};
			}
		);
	}
	
	
	function fnList() {
		history.back();
	}

	// 저장
	function goSave(isRequestAppr) {
		
		var frm = document.main_form;	
		
	     // validation check
     	if($M.validation(frm) == false) {
     		return;
     	}
	     
    	if($M.checkRangeByFieldName("check_st_dt", "check_ed_dt", true) == false) {				
			return;
		};  
	     
		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList = AUIGrid.getOrgGridData(auiGrid);
		
		
		if(gridAllList.length < 1 ){
			alert("저장할 데이터가 없습니다.")
			return;
		}
		
	     
    	if (isRequestAppr != undefined){
			$M.setValue("save_mode", "appr"); // 결재요청
			if(confirm("결재 후 수정 및 삭제가 제한됩니다.\n계속 진행하시겠습니까?") == false){
				return false;
			}
		} else {
			$M.setValue("save_mode", "save"); //저장
			if(confirm("저장하시겠습니까?") == false){
				return false;
			}
		} 
	     
	     
	     
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

		partCnt = partCnt -1;
		
		var option = {
				isEmpty : true
		};
		
		var param = {
								
				//사이클체크 마스터 세팅		
							
				check_mon : 	$M.getValue("check_mon"),
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
		

		$M.goNextPageAjax(this_page+"/save", $M.toGetParam(param), {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("저장이 완료되었습니다.");
	    			fnList();
				}
			}
		);
	}
	
	//결재요청시
	function goRequestApproval() {
		goSave('requestAppr');
	}
	

	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "CYCLE_CHECK 등록");
	}

	function goPartList() {
		
		$M.setValue("only_diff_yn",   $M.getValue("only_diff_yn") == "Y" ? "N" : "Y" );
	
		goSearch();
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
			<div class="main-title detail">
				<div class="detail-left approval-left" style="align-items: center;">
					<div class="left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
						<div style="min-width:80px; margin-top: auto; margin-bottom: auto; margin-right: 10px;">
							<span class="condition-item">상태 : ${apprBean.appr_proc_status_name}</span>
						</div>
					</div>
				</div>
				<!-- 결재영역 -->
				<div class="p10"> 
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
				<!-- /결재영역 -->
	<!-- /결제 영역 -->			
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents">
	<!-- 폼테이블 -->		
	
		
			<input type="hidden" id="count_remark" 			name="count_remark" 		value="" >
			<input type="hidden" id="warehouse_cd" 			name="warehouse_cd" 		value="${inputParam.s_warehouse_cd}" >
			<input type="hidden" id="check_mon" 			name="check_mon" 			value="${inputParam.check_mon}" >
			<input type="hidden" id="diff_total_cnt" 		name="diff_total_cnt" 		value="${cycle.diff_total_cnt}" >
			<input type="hidden" id="check_total_cnt" 		name="check_total_cnt" 		value="${cycle.check_total_cnt}" >
			<input type="hidden" id="adjust_total_cnt" 		name="adjust_total_cnt" 	value="${cycle.adjust_total_cnt}" >
			<input type="hidden" id="adjust_total_amt" 		name="adjust_total_amt" 	value="${cycle.adjust_total_amt}" >
			<input type="hidden" id="last_check_st_dt" 	 	name="last_check_st_dt"  	value="${cycle.check_st_dt}"	>
			<input type="hidden" id="last_check_ed_dt" 		name="last_check_ed_dt" 	value="${cycle.check_ed_dt}" >
			<input type="hidden" id="last_check_ed_dt" 		name="last_check_ed_dt" 	value="${cycle.check_ed_dt}" >
			<input type="hidden" id="only_diff_yn" 			name="only_diff_yn" 		value="N" >
	
			<div>
				<table class="table-border">
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
							<td>${inputParam.s_year}년 ${inputParam.s_mon}월</td>
							<th class="text-right">품의번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control  width120px" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right">품의창고</th>
							<td>
								<input type="text" class="form-control width120px" value="${inputParam.s_warehouse_name}" readonly="readonly"  >
							</td>
							<th class="text-right">조사기간</th>
							<td>
								<div class="form-row inline-pd" style="width:265px;" >
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="check_st_dt" name="check_st_dt" dateformat="yyyy-MM-dd" alt="조회 시작일"  value="${inputParam.check_st_dt}">
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="check_ed_dt" name="check_ed_dt" dateformat="yyyy-MM-dd" alt="조회 완료일"   value="${inputParam.check_ed_dt}">
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
								<span class="font-11 spacing-sm text-dark">(재고조정 완료건 : <span id="sp_adjust_total_cnt2"  name="sp_adjust_total_cnt2" >${cycle.adjust_total_cnt}</span>건 포함)</span>
							</td>
							<th class="text-right">조사총금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control text-right" id="check_total_amt" name="check_total_amt" value="${cycle.check_total_amt}"  format="decimal" readonly="readonly">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">조사차이금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-4">
										<input type="text" class="form-control text-right" id="diff_total_amt" name="diff_total_amt" value="${cycle.diff_total_amt}"  format="decimal" readonly="readonly" >
									</div>
									<div class="col-1">원</div>
									<div class="col-2 text-right">백분율</div>
									<div class="col-3">
										<input type="text" class="form-control text-right" id="check_rate" name="check_rate" value="${cycle.check_rate}" readonly="readonly" >
									</div>
									<div class="col-2">%</div>
								</div>
							</td>				
						</tr>
						<tr>
							<th clsas="text-right">비고</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 100%;" id="remark_master" name="remark_master" ></textarea>
							</td>
							
							<th class="text-right">걸재의견</th>
							<td rowspan="2" colspan="3" class="v-align-top">
								<div style="min-height: 82px;">
									<!--  -->
									<table class="table-border doc-table md-table">
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
							</td>
						</tr>
					</tbody>
				</table>
			</div>	
	<!-- /폼테이블 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>재고조사결과</h4>
					<div class="btn-group">
						<div class="right"  id="btnHideTop" ><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" class="mt10" style="margin-top: 5px; width: 100%;height: 400px;"></div>
				<div id="auiGridDiff" class="mt10" style="margin-top: 5px; width: 100%;height: 400px;display:none;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt" >0</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
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

<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->	

</form>
</body>
</html>